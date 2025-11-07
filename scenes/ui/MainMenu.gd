extends Control

func _ready():
	Game.load_progress()

func _on_Jugar_pressed():
	get_tree().change_scene("res://scenes/World.tscn")


func _on_Opciones_pressed():
	get_tree().change_scene("res://scenes/ui/Options.tscn")


func _on_Salir_pressed():
	get_tree().quit()
