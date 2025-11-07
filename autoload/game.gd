extends Node

var rng := RandomNumberGenerator.new()
var run_seed := 0
var camp_safe_radius := 300.0 

var carried := {}  
var banked  := {} 


const TAMALES := [
	{"name":"Frijol",   "weight":35},
	{"name":"Ranchero", "weight":25},
	{"name":"Elote",    "weight":20},
	{"name":"Rajas",    "weight":18},
	{"name":"Piña",     "weight":15},
	{"name":"Verde",    "weight":12},
	{"name":"Zacahuil", "weight":8},
	{"name":"Mixiote",  "weight":6},
	{"name":"Fresa",    "weight":4},
	{"name":"Mole",     "weight":2},
]


var base_enemy_speed := 60.0
var base_spawn_rate := 0.012 
var run_start_camp_pos := Vector2.ZERO

func _ready():
	rng.seed = Time.get_unix_time_from_system()
	run_seed = rng.randi()

func reset_run(camp_pos: Vector2):
	run_start_camp_pos = camp_pos
	carried.clear()

func distance_factor(player_pos: Vector2) -> float:
	var d := player_pos.distance_to(run_start_camp_pos) / 512.0
	return clamp(1.0 + d, 1.0, 6.0)

func add_carried(name: String, amount := 1):
	carried[name] = (carried.get(name, 0) + amount)

func bank_all():
	for k in carried.keys():
		banked[k] = (banked.get(k, 0) + carried[k])
	carried.clear()
	save_progress()

func lose_carried():
	carried.clear()

func pick_random_tamal_name() -> String:
	var total := 0
	for t in TAMALES: total += t.weight
	var roll := rng.randi_range(1, total)
	var acc := 0
	for t in TAMALES:
		acc += t.weight
		if roll <= acc:
			return t.name
	return "Frijol"

# Guardado simple a JSON (base de datos "lite")
const SAVE_PATH := "user://savegame.json"

func save_progress():
	var data = {
		"banked": banked,
		"seed": run_seed
	}
	var f = File.new()
	if f.open(SAVE_PATH, File.WRITE) == OK:
		f.store_string(to_json(data))
		f.close()

func load_progress():
	var f = File.new()
	if not f.file_exists(SAVE_PATH):
		return
	if f.open(SAVE_PATH, File.READ) == OK:
		var data = parse_json(f.get_as_text())
		f.close()
		if typeof(data) == TYPE_DICTIONARY:
			banked = data.get("banked", {})
			run_seed = data.get("seed", run_seed)
