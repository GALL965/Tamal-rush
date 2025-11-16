extends Area2D

export var camp_id := 1
export var safe_radius := 300.0

var run_already_ended := false

func _ready():
	add_to_group("camp")
	Game.set_camp_data(camp_id, safe_radius, global_position)


func _on_Camp_body_entered(body):
	if body.name == "Player":
		Game.bank_all()
		Game.save_stats()



func _on_Camp_body_exited(body):
	pass
