extends Control

onready var slider := $VBoxContainer/HSlider

func _ready():
	var bus := AudioServer.get_bus_index("Master")
	slider.value = db2linear(AudioServer.get_bus_volume_db(bus))

func _on_HSlider_value_changed(value):
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear2db(value))

func _on_Back_pressed():
	get_tree().change_scene("res://scenes/ui/MainMenu.tscn")
