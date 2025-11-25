extends CanvasLayer

func _ready() -> void:
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS

func mostrar() -> void:
	visible = true
	var btn := $CenterContainer/VBoxContainer/Reanudar if has_node("CenterContainer/VBoxContainer/Reanudar") else null
	if btn:
		btn.grab_focus()

func ocultar() -> void:
	visible = false

func _on_Button_pressed() -> void:
	get_tree().paused = false
	ocultar()

func _on_Button2_pressed() -> void:
	get_tree().paused = false
	
	var path := "res://scenes/ui/MainMenu.tscn"

	if ResourceLoader.exists(path):
		get_tree().change_scene(path) 
	else:
		get_tree().quit()
