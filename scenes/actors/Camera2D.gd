
extends Camera2D

func _ready():
	smoothing_enabled = false 
	
func _process(_dt):

	var z := zoom
	if z.x == 0 or z.y == 0:
		return
	global_position = (global_position * z).round() / z
