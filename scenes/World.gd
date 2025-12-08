# res://scenes/World.gd
extends Node2D


# Escenas que se spawnean
const TAMAL_SCENE  := preload("res://scenes/world/Tamale.tscn")
const ENEMY_SCENE  := preload("res://scenes/actors/Enemy.tscn")
const CAMP_SCENE   := preload("res://scenes/world/Camp.tscn")
const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")



# =========================
# CONFIG
# =========================
const TILE_SIZE := 64    # antes 32
const CHUNK_SIZE := 12   # chunk ~ 768px

const LOAD_RADIUS_CHUNKS  := 2   # terreno cargado (5x5 chunks)
const SPAWN_RADIUS_CHUNKS := 1   # spawn solo en el anillo interno (3x3)
const UNLOAD_RADIUS_CHUNKS := 3

const DESPAWN_CHECK_INTERVAL := 0.5
const GEN_BUDGET_PER_FRAME := 900

const MAX_ENEMIES_GLOBAL := 60
const MAX_ENEMIES_PER_CHUNK := 3
const MAX_TAMALES_PER_CHUNK := 6

# Decor ID (arbusto) en el TileSet de $Decor
const D_BUSH  := 0            

# nodos
onready var ground   := $Ground
onready var decor    := $Decor
onready var entities := $Entities
onready var hud      := $HUD

# =====
var rng := RandomNumberGenerator.new()
var ground_noise := OpenSimplexNoise.new()    
var GROUND_IDS: PoolIntArray = PoolIntArray()  

var player
var camp_instance
var loaded_chunks := {}       
var gen_queue := []            
var DESPAWN_DISTANCE_PIXELS := 0
var _despawn_acc := 0.0

func _collect_ground_ids() -> PoolIntArray:
	var ids := PoolIntArray()
	var ts = ground.tile_set
	for id in ts.get_tiles_ids():
		ids.append(id)  
	return ids


func _pick_ground_id_uniform(cell: Vector2, chunk_key: Vector2) -> int:
	if GROUND_IDS.size() == 0:
		return 0
	var rr := RandomNumberGenerator.new()
	var s := int(Game.run_seed)
	s = s ^ int(chunk_key.x)*73856093 ^ int(chunk_key.y)*19349663
	s = s ^ int(cell.x)*83492791 ^ int(cell.y)*2971215073
	rr.seed = s & 0x7fffffff
	return GROUND_IDS[rr.randi() % GROUND_IDS.size()]

func world_to_chunk(p: Vector2) -> Vector2:
	return Vector2(floor(p.x/(CHUNK_SIZE*TILE_SIZE)), floor(p.y/(CHUNK_SIZE*TILE_SIZE)))

func chunk_to_world_origin(c: Vector2) -> Vector2:
	return Vector2(c.x*CHUNK_SIZE*TILE_SIZE, c.y*CHUNK_SIZE*TILE_SIZE)


func _ready():
	print("Ground cell_size=", ground.cell_size, " scale=", ground.scale)
	_init_pause()

	# Distancia de limpieza
	DESPAWN_DISTANCE_PIXELS = (UNLOAD_RADIUS_CHUNKS + 2) * CHUNK_SIZE * TILE_SIZE

	# Asegurar que Player y Camp existen antes de usarlos
	yield(get_tree(), "idle_frame")

	# Obtener instancias del arbolito
	player = $Entities.get_node("Player")
	camp_instance = $Entities.get_node("Camp")

	# inicio run
	rng.seed = Game.run_seed
	Game.reset_run(camp_instance.global_position)
	print("RUN INIT OK, state=", Game.game_state)
	
	
	ground_noise.seed = int(Game.run_seed * 31)
	ground_noise.octaves = 3
	ground_noise.period = 64.0
	ground_noise.persistence = 0.55

	# IDs de los tiles
	GROUND_IDS = _collect_ground_ids()

	# Activar proceso del World
	set_process(true)


func _process(delta):
	if Game.game_state == Game.STATE_RUNNING:
		Game.time_accumulator += delta

	_stream_chunks_around_player()
	_update_bush_stealth()
	_process_gen_queue()

	_despawn_acc += delta
	if _despawn_acc >= DESPAWN_CHECK_INTERVAL:
		_despawn_far_entities()
		_despawn_acc = 0.0

func _stream_chunks_around_player():
	if player == null: return
	var cpos := world_to_chunk(player.global_position)
	for x in range(cpos.x-LOAD_RADIUS_CHUNKS, cpos.x+LOAD_RADIUS_CHUNKS+1):
		for y in range(cpos.y-LOAD_RADIUS_CHUNKS, cpos.y+LOAD_RADIUS_CHUNKS+1):
			var key := Vector2(x, y)
			if not loaded_chunks.has(key):
				_generate_chunk(key)

func _generate_chunk(cxy: Vector2):
	loaded_chunks[cxy] = true

	var origin := chunk_to_world_origin(cxy)


	rng.seed = int(Game.run_seed + int(cxy.x) * 73856093 + int(cxy.y) * 19349663)


	for tx in range(CHUNK_SIZE):
		for ty in range(CHUNK_SIZE):
			var cell := (origin / TILE_SIZE) + Vector2(tx, ty)
			var gid  := _pick_ground_id_uniform(cell, cxy)

			gen_queue.append({
				"type": "tile",
				"map": "ground",
				"cell": cell,
				"id": gid
			})

			# --- 2) DECOR opcional (arbustos) ---

			if rng.randf() < 0.07:
				gen_queue.append({
					"type": "tile",
					"map": "decor",
					"cell": cell,
					"id": D_BUSH
				})


	for tx in [0, CHUNK_SIZE - 1]:
		for ty in range(CHUNK_SIZE):
			_spawn_edge_entities(origin, tx, ty)
	for ty in [0, CHUNK_SIZE - 1]:
		for tx in range(CHUNK_SIZE):
			_spawn_edge_entities(origin, tx, ty)

func _spawn_edge_entities(origin: Vector2, tx: int, ty: int) -> void:
	var wpos := origin + Vector2(tx * TILE_SIZE, ty * TILE_SIZE)


	if rng.randf() < Game.base_spawn_rate * 0.7:
		gen_queue.append({
			"type": "spawn",
			"scene": TAMAL_SCENE,
			"pos": wpos + Vector2(TILE_SIZE/2, TILE_SIZE/2),
			"tamal_name": Game.pick_random_tamal_name()
		})


	if get_tree().get_nodes_in_group("enemies").size() < MAX_ENEMIES_GLOBAL \
	and rng.randf() < Game.base_spawn_rate * 0.35:
		gen_queue.append({
			"type": "spawn",
			"scene": ENEMY_SCENE,
			"pos": wpos + Vector2(TILE_SIZE/2, TILE_SIZE/2)
		})

func _update_bush_stealth():
	if player == null: return
	var cell = decor.world_to_map(player.global_position)
	var is_bush = (decor.get_cellv(cell) == D_BUSH)
	if "set_in_bush" in player:
		player.set_in_bush(is_bush)

func respawn_player_at_camp():
	player.global_position = Game.run_start_camp_pos + Vector2(0, -TILE_SIZE*2)

func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _process_gen_queue():
	var budget := GEN_BUDGET_PER_FRAME
	while budget > 0 and gen_queue.size() > 0:
		var op = gen_queue.pop_front()
		if op.type == "tile":
			if op.map == "ground":
				ground.set_cellv(op.cell, op.id)
			else:
				decor.set_cellv(op.cell, op.id)
			budget -= 1
		elif op.type == "spawn":
			var inst = op.scene.instance()
			inst.global_position = op.pos
			entities.add_child(inst)
			if op.has("tamal_name"):
				inst.tamal_name = op.tamal_name
			budget -= 30



func _despawn_far_entities():
	if not is_instance_valid(player):
		return

	var px = player.global_position

	for child in entities.get_children():
		if not is_instance_valid(child):
			continue
		if child == player:
			continue
		if child.is_in_group("camp"):
			continue
		if not (child is Node2D):
			continue

		if child.global_position.distance_to(px) > DESPAWN_DISTANCE_PIXELS:
			child.queue_free()
			
#Pause we
#----------------------------------------------------
# File: res://scenes/World.gd

onready var pause_menu := $PauseMenu

func _init_pause():
	pause_mode = Node.PAUSE_MODE_PROCESS
	if pause_menu:
		pause_menu.visible = false
		pause_menu.pause_mode = Node.PAUSE_MODE_PROCESS


func _toggle_pause():
	if not pause_menu:
		print("[Pause] No existe PauseMenu dentro de World.")
		return

	if get_tree().paused:
		get_tree().paused = false
		pause_menu.ocultar()
	else:
		get_tree().paused = true
		pause_menu.mostrar()
		
		

func _exit_tree():
	if Game.game_state == Game.STATE_RUNNING:
		Game.end_game_session()
		Game.save_stats()
		Game.send_stats_to_api()
		print("RUN FINALIZADA al salir de World, tiempo=", Game.total_time_played)
