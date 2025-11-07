extends CanvasLayer

onready var carried_l := $HBoxContainer/Carried
onready var banked_l  := $HBoxContainer/Banked
onready var dist_l    := $Distance
var player: Node = null

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	set_process(true)

func _process(_delta):
	carried_l.text = "En mano: " + _dict_to_text(Game.carried)
	banked_l.text  = "Guardado: " + _dict_to_text(Game.banked)
	if player:
		var d = int(player.global_position.distance_to(Game.run_start_camp_pos))
		dist_l.text = "Distancia al camp: %d" % d

func _dict_to_text(d: Dictionary) -> String:
	if d.empty(): return "—"
	var parts := []
	for k in d.keys():
		parts.append("%s:%d" % [k, d[k]])
	return ", ".join(parts)
