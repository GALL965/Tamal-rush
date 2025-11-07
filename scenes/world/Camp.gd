extends Area2D

func _ready():
	add_to_group("camp")

func _on_Camp_body_entered(body):
	if body.name == "Player":
		Game.bank_all()

func _on_Camp_body_exited(body):
	pass
