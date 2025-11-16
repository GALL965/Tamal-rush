extends Area2D

export(String) var tamal_name := "Frijol"
export(int) var tamal_id := 0
export(int) var value := 1

func _ready() -> void:
	# Registrar aparición del tamal para las stats
	Game.register_tamal_spawn(
		tamal_id,
		tamal_name,
		value,
		global_position
	)


func _on_tamale_body_entered(body):
	if body.name == "Player":
		# 1) SISTEMA VIEJO: suma al inventario en mano
		Game.add_carried(tamal_name, 1)

		# 2) SISTEMA NUEVO: registra en las stats de la run
		Game.register_player_tamal_pick(
			tamal_id,
			tamal_name,
			value,
			global_position
		)
		queue_free()
