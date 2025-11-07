extends Area2D

export(String) var tamal_name := "Frijol"

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body.name == "Player":
		Game.add_carried(tamal_name, 1)
		queue_free()
