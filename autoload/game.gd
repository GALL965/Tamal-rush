extends Node
# ============================================
#  Autoload de Tamal Rush
#  - Mantiene el guardado original (savegame.json)
#  - Además guarda estadísticas para BD (tamal_rush_stats.json)
# ============================================

var carried := {}   # lo que traes en la mano en esta run
var banked  := {}   # lo guardado definitivamente (entre runs)

var base_enemy_speed := 60.0
var base_spawn_rate := 0.012    # si ya la definiste antes, deja solo una



# --------- CONSTANTES DE GUARDADO ----------
const SAVE_PATH_GAME  := "user://savegame.json"          # guardado viejo (tamales bancados)
const SAVE_PATH_STATS := "user://tamal_rush_stats.json"  # NUEVO: historial de runs para BD
# --------- CONFIG DE SPAWNS ----------



# --------- RANDOM / RUN ----------
var rng := RandomNumberGenerator.new()
var run_seed := 0
var camp_safe_radius := 300.0
var run_start_camp_pos := Vector2()

# Catálogo de tamales (para el sistema viejo)
const TAMALES := [
	{"name":"Frijol",   "weight":35},
	{"name":"Ranchero", "weight":25},
	{"name":"Elote",    "weight":20},
	{"name":"Rajas",    "weight":18},
	{"name":"Piña",     "weight":15},
]

# --------- ESTADO GENERAL DE LA PARTIDA (STATS) ----------
const STATE_IDLE    := 0
const STATE_RUNNING := 1
const STATE_ENDED   := 2
var game_state := STATE_IDLE

var _start_time_unix := 0
var _end_time_unix   := 0
var start_time_str := ""
var end_time_str   := ""
var total_time_played := 0.0

# --------- TABLA: Player ----------
var player_id := 1
var player_name := "Mapache"
var speed := 0.0
var dash_power := 0.0
var hidden := false
var tamales_collected := 0

# --------- TABLA: Camp ----------
var camp_id := 1
var safe_radius := 0.0
var camp_location := Vector2()
var tamales_banked := 0

# --------- TABLA: Tamale ----------
var tamales := []        # lista de diccionarios de tamales

# --------- TABLA: PlayerTamale ----------
var player_tamales := {} # tamal_id -> cantidad

# --------- TABLA: CampTamale ----------
var camp_tamales := {}   # tamal_id -> cantidad_banked

# --------- TABLAS: Enemy / EnemyLog ----------
var enemies := []        # lista de enemigos
var enemy_logs := []     # lista de logs de eventos
var enemies_encountered := 0


func _ready() -> void:
	rng.randomize()
	load_game()     # carga savegame.json (banked + seed)
	reset_stats()   # limpia stats de la run actual


# ==================================================
#  RESET DE STATS (NO TOCA BANKED)
# ==================================================
func reset_stats() -> void:
	game_state = STATE_IDLE

	_start_time_unix = 0
	_end_time_unix = 0
	start_time_str = ""
	end_time_str = ""
	total_time_played = 0.0

	# Player
	speed = 0.0
	dash_power = 0.0
	hidden = false
	tamales_collected = 0

	# Camp (solo stats de esta run)
	camp_id = 1
	safe_radius = 0.0
	camp_location = Vector2()
	tamales_banked = 0

	# Stats relacionadas
	tamales.clear()
	player_tamales.clear()
	camp_tamales.clear()
	enemies.clear()
	enemy_logs.clear()
	enemies_encountered = 0

	# carried se limpia al empezar la run
	carried.clear()


# ==================================================
#  INICIO / FIN DE UNA RUN
# ==================================================
func reset_run(camp_pos: Vector2) -> void:
	# Llamar esto desde World.gd al iniciar una partida
	run_start_camp_pos = camp_pos
	carried.clear()
	rng.randomize()
	run_seed = rng.randi()

	start_game_session()
	set_camp_data(camp_id, camp_safe_radius, camp_pos)


func start_game_session() -> void:
	game_state = STATE_RUNNING
	_start_time_unix = OS.get_unix_time()
	start_time_str = _get_iso_datetime()


func end_game_session() -> void:
	if game_state != STATE_RUNNING:
		return
	_end_time_unix = OS.get_unix_time()
	end_time_str = _get_iso_datetime()
	total_time_played = float(_end_time_unix - _start_time_unix)
	game_state = STATE_ENDED


# ==================================================
#  FUNCIONES DE PLAYER (STATS)
# ==================================================
func set_player_basic_data(p_name: String, p_speed: float, p_dash_power: float) -> void:
	player_name = p_name
	speed = p_speed
	dash_power = p_dash_power


func set_player_hidden(state: bool) -> void:
	hidden = state


func register_player_tamal_pick(tamal_id: int, tamal_name: String, value: int, spawn_pos: Vector2) -> void:
	tamales_collected += 1

	# PlayerTamale
	if not player_tamales.has(tamal_id):
		player_tamales[tamal_id] = 1
	else:
		player_tamales[tamal_id] += 1

	# Tamale (marcar como recogido o registrarlo)
	var found := false
	for t in tamales:
		if t.tamal_id == tamal_id:
			t.collected = true
			found = true
			break

	if not found:
		tamales.append({
			"tamal_id": tamal_id,
			"tamal_name": tamal_name,
			"value": value,
			"spawn_location_x": spawn_pos.x,
			"spawn_location_y": spawn_pos.y,
			"collected": true
		})


func register_tamal_spawn(tamal_id: int, tamal_name: String, value: int, spawn_pos: Vector2) -> void:
	tamales.append({
		"tamal_id": tamal_id,
		"tamal_name": tamal_name,
		"value": value,
		"spawn_location_x": spawn_pos.x,
		"spawn_location_y": spawn_pos.y,
		"collected": false
	})


# ==================================================
#  CAMP (STATS + GUARDADO VIEJO)
# ==================================================
func set_camp_data(p_camp_id: int, p_safe_radius: float, pos: Vector2) -> void:
	camp_id = p_camp_id
	safe_radius = p_safe_radius
	camp_location = pos

# ==================================================
#  ENEMIGOS (por ahora solo stubs, para conectar luego)
# ==================================================
func register_enemy_spawn(enemy_id: int, enemy_type: String, patrol_speed: float, chase_speed: float, detect_range: float, camp_ref: int) -> void:
	enemies.append({
		"enemy_id": enemy_id,
		"type": enemy_type,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"detect_range": detect_range,
		"is_chasing": false,
		"camp_id": camp_ref
	})


func set_enemy_chasing(enemy_id: int, chasing: bool) -> void:
	for e in enemies:
		if e.enemy_id == enemy_id:
			e.is_chasing = chasing
			break


func log_enemy_event(enemy_id: int, event_type: String) -> void:
	if event_type == "detect":
		enemies_encountered += 1

	enemy_logs.append({
		"log_id": 0,
		"enemy_id": enemy_id,
		"event_type": event_type,
		"timestamp": _get_iso_datetime()
	})


# ==================================================
#  DISTANCE FACTOR (COMPAT Enemy.gd)
# ==================================================
func distance_factor(pos: Vector2) -> float:
	# Versión sencilla (puedes mejorarla luego si quieres)
	return 1.0


# ==================================================
#  GUARDADO ORIGINAL DEL JUEGO (savegame.json)
# ==================================================
func save_game() -> void:
	var data := {
		"banked": banked,
		"seed": run_seed
	}
	var f := File.new()
	if f.open(SAVE_PATH_GAME, File.WRITE) == OK:
		f.store_string(to_json(data))
		f.close()
		print("Guardado juego en: ", SAVE_PATH_GAME)


func load_game() -> void:
	var f := File.new()
	if not f.file_exists(SAVE_PATH_GAME):
		return

	if f.open(SAVE_PATH_GAME, File.READ) == OK:
		var txt := f.get_as_text()
		f.close()
		if txt != "":
			var d = parse_json(txt)
			if typeof(d) == TYPE_DICTIONARY:
				banked = d.get("banked", {})
				run_seed = int(d.get("seed", 0))


# ==================================================
#  GUARDADO DE ESTADÍSTICAS PARA BD (tamal_rush_stats.json)
# ==================================================
func build_payload() -> Dictionary:
	return {
		"player": {
			"player_id": player_id,
			"name": player_name,
			"speed": speed,
			"dash_power": dash_power,
			"hidden": hidden,
			"tamales_collected": tamales_collected
		},
		"camp": {
			"camp_id": camp_id,
			"safe_radius": safe_radius,
			"location_x": camp_location.x,
			"location_y": camp_location.y,
			"tamales_banked": tamales_banked
		},
		"tamales": tamales,
		"player_tamales": player_tamales,
		"camp_tamales": camp_tamales,
		"enemies": enemies,
		"enemy_logs": enemy_logs,
		"game_stats": {
			"start_time": start_time_str,
			"end_time": end_time_str,
			"tamales_collected": tamales_collected,
			"tamales_banked": tamales_banked,
			"enemies_encountered": enemies_encountered,
			"total_time_played": total_time_played
		}
	}


func save_stats() -> void:
	# Carga stats anteriores si existen
	var f := File.new()
	var data := {}

	if f.file_exists(SAVE_PATH_STATS):
		if f.open(SAVE_PATH_STATS, File.READ) == OK:
			var txt := f.get_as_text()
			f.close()
			if txt != "":
				var parsed = parse_json(txt)
				if typeof(parsed) == TYPE_DICTIONARY:
					data = parsed

	# Aseguramos array de runs
	if not data.has("runs"):
		data["runs"] = []

	# Agregamos la run actual
	data["runs"].append(build_payload())

	# También guardamos info persistente útil
	data["banked"] = banked
	data["seed"]   = run_seed
	data["tamales"] = tamales

	# Guardamos en archivo de stats
	if f.open(SAVE_PATH_STATS, File.WRITE) == OK:
		f.store_string(to_json(data))
		f.close()
		print("Guardado stats en: ", SAVE_PATH_STATS)
	else:
		print("Error al guardar stats")


func to_json_string() -> String:
	return to_json(build_payload())


# ==================================================
#  UTILIDAD: FECHA/HORA ISO
# ==================================================
func _get_iso_datetime() -> String:
	var dt := OS.get_datetime()
	return "%04d-%02d-%02dT%02d:%02d:%02d" % [
		dt.year, dt.month, dt.day,
		dt.hour, dt.minute, dt.second
	]

func load_progress() -> void:
	# Compatibilidad con código viejo
	load_game()
	
	
func pick_random_tamal_name() -> String:
	# Elige un tipo de tamal según peso (probabilidad)
	var total_weight := 0.0
	for t in TAMALES:
		total_weight += float(t["weight"])

	var r := rng.randf() * total_weight
	var acc := 0.0

	for t in TAMALES:
		acc += float(t["weight"])
		if r <= acc:
			return t["name"]

	# Por seguridad, si algo raro pasa, devolvemos el primero
	return TAMALES[0]["name"]

func add_carried(name: String, amount := 1) -> void:
	# Suma lo que llevas "en la mano" (versión vieja)
	carried[name] = (carried.get(name, 0) + amount)


func bank_all() -> void:
	# Pasa TODO lo que traes en la mano a guardado
	for k in carried.keys():
		banked[k] = (banked.get(k, 0) + carried[k])
		# stats nuevas:
		tamales_banked += carried[k]
	carried.clear()
	save_game()  # guarda en savegame.json (como antes)


func lose_carried() -> void:
	carried.clear()
