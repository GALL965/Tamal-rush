extends Node2D

const TILE_SIZE  := 16
const CHUNK_SIZE := 48

const MAX_ENEMIES_GLOBAL := 60   # ajusta a tu gusto

var DESPAWN_DISTANCE_PIXELS = 0     # la calculamos en _ready()

const DESPAWN_CHECK_INTERVAL := 0.5  # segundos
var _despawn_acc := 0.0

const LOAD_RADIUS_CHUNKS  := 2   # cargar terreno
const SPAWN_RADIUS_CHUNKS := 1   # spawnear enemigos/tamales solo en el anillo interno
const UNLOAD_RADIUS_CHUNKS := 3  # descargar lejos

const MAX_ENEMIES_PER_CHUNK := 3
const MAX_TAMALES_PER_CHUNK := 6

const GEN_BUDGET_PER_FRAME := 900  # “operaciones” por frame (tiles + instancias)

var gen_queue := []    

const TAMAL_SCENE := preload("res://scenes/world/Tamale.tscn")
const ENEMY_SCENE := preload("res://scenes/actors/Enemy.tscn")
const CAMP_SCENE  := preload("res://scenes/world/Camp.tscn")
const PLAYER_SCENE:= preload("res://scenes/actors/Player.tscn")

onready var ground := $Ground
onready var decor  := $Decor
onready var entities := $Entities
onready var hud := $HUD

var camp_instance
var player

var loaded_chunks := {} 


const T_GRASS := 0
const T_WATER := 1
const T_ROCK  := 2
const D_BUSH  := 0


var rng := RandomNumberGenerator.new()

func _ready():
	DESPAWN_DISTANCE_PIXELS = (UNLOAD_RADIUS_CHUNKS + 2) * CHUNK_SIZE * TILE_SIZE
	rng.seed = Game.run_seed
	player = $Entities/Player
	camp_instance = $Entities/Camp
	Game.reset_run(camp_instance.global_position)
	set_process(true)



func _process(_delta):
	_stream_chunks_around_player()
	_update_bush_stealth()
	_process_gen_queue()
	_despawn_acc += _delta
	if _despawn_acc >= DESPAWN_CHECK_INTERVAL:
		_despawn_far_entities()
		_despawn_acc = 0.0



func _spawn_player_and_camp():
	player = PLAYER_SCENE.instance()
	entities.add_child(player)
	var camp = CAMP_SCENE.instance()
	entities.add_child(camp)
	camp.global_position = Vector2.ZERO
	player.global_position = Vector2(0, -TILE_SIZE*2)
	camp_instance = camp
	Game.reset_run(camp.global_position)

func world_to_chunk(p: Vector2) -> Vector2:
	return Vector2(floor(p.x/(CHUNK_SIZE*TILE_SIZE)), floor(p.y/(CHUNK_SIZE*TILE_SIZE)))

func chunk_to_world_origin(c: Vector2) -> Vector2:
	return Vector2(c.x*CHUNK_SIZE*TILE_SIZE, c.y*CHUNK_SIZE*TILE_SIZE)

func _stream_chunks_around_player():
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
			var wpos := origin + Vector2(tx * TILE_SIZE, ty * TILE_SIZE)


			var n := rng.randf()
			var tile_id := T_GRASS
			if n < 0.10:
				tile_id = T_WATER
			elif n < 0.20:
				tile_id = T_ROCK
			ground.set_cellv((origin / TILE_SIZE) + Vector2(tx, ty), tile_id)


			if tile_id == T_GRASS and rng.randf() < 0.12:
				decor.set_cellv((origin / TILE_SIZE) + Vector2(tx, ty), D_BUSH)


			if tx in [0, CHUNK_SIZE - 1] or ty in [0, CHUNK_SIZE - 1]:
				var df := Game.distance_factor(wpos)


				if rng.randf() < Game.base_spawn_rate * df * 0.7 and tile_id == T_GRASS:
					var t := TAMAL_SCENE.instance()
					t.tamal_name = Game.pick_random_tamal_name()
					t.global_position = wpos + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
					entities.add_child(t)


				if tile_id == T_GRASS \
				and get_tree().get_nodes_in_group("enemies").size() < MAX_ENEMIES_GLOBAL \
				and rng.randf() < Game.base_spawn_rate * df * 0.35:
					var e := ENEMY_SCENE.instance()
					e.global_position = wpos + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
					entities.add_child(e)


func _update_bush_stealth():

	var cell = decor.world_to_map(player.global_position)
	var is_bush = (decor.get_cellv(cell) == D_BUSH)
	player.set_in_bush(is_bush)

func respawn_player_at_camp():
	player.global_position = Game.run_start_camp_pos + Vector2(0, -TILE_SIZE*2)



func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused


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
			# extras
			if op.has("tamal_name"):
				inst.tamal_name = op.tamal_name
			budget -= 30  


func _despawn_far_entities():
	if player == null: return
	var px = player.global_position
	for child in entities.get_children():

		if child == player: continue
		if child.is_in_group("camp"): continue

		if child.global_position.distance_to(px) > DESPAWN_DISTANCE_PIXELS:
			child.queue_free()
