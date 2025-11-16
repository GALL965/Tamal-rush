extends Control

onready var _tween := $Tween
onready var _vbox := $VBoxContainer
onready var _btn_jugar := $VBoxContainer/Jugar
onready var _btn_opciones := $VBoxContainer/Opciones
onready var _btn_salir := $VBoxContainer/Salir

const COLOR_NORMAL := Color(1, 1, 1, 1)
const COLOR_HOVER  := Color(0.85, 0.85, 0.85, 1)

func _ready():
	Game.load_progress()

	# Estado inicial de los botones
	for b in [_btn_jugar, _btn_opciones, _btn_salir]:
		b.rect_scale = Vector2.ONE
		b.modulate = COLOR_NORMAL
		# Hover
		b.connect("mouse_entered", self, "_on_button_mouse_entered", [b])
		b.connect("mouse_exited", self, "_on_button_mouse_exited", [b])
		# Animación extra al presionar (además de las ya conectadas en el .tscn)
		b.connect("pressed", self, "_on_button_pressed_anim", [b])

	_play_intro_animation()

# =====================
# LÓGICA DE NAVEGACIÓN
# =====================

func _on_Jugar_pressed():
	_start_exit_animation("_go_to_world")

func _go_to_world():
	get_tree().change_scene("res://scenes/World.tscn")

func _on_Opciones_pressed():
	_start_exit_animation("_go_to_options")

func _go_to_options():
	get_tree().change_scene("res://scenes/ui/Opciones.tscn")

func _on_Salir_pressed():
	_start_exit_animation("_quit_game")

func _quit_game():
	get_tree().quit()

# =====================
# ANIMACIONES MENÚ
# =====================

# Entrada de todos los botones
func _play_intro_animation():
	# VBox empieza un poco abajo y transparente
	_vbox.modulate.a = 0.0
	_vbox.rect_position += Vector2(0, 40)

	_tween.interpolate_property(
		_vbox, "rect_position",
		_vbox.rect_position,
		_vbox.rect_position - Vector2(0, 40),
		0.35,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
	_tween.interpolate_property(
		_vbox, "modulate:a",
		0.0,
		1.0,
		0.35,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	_tween.start()

# Salida de todos los botones (cuando se pulsa cualquiera)
func _start_exit_animation(next_method_name):
	_tween.stop_all()

	var start_pos = _vbox.rect_position
	var end_pos = start_pos + Vector2(0, 40)

	_tween.interpolate_property(
		_vbox, "rect_position",
		start_pos,
		end_pos,
		0.25,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)
	_tween.interpolate_property(
		_vbox, "modulate:a",
		1.0,
		0.0,
		0.25,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)

	_tween.connect(
		"tween_all_completed",
		self,
		"_on_exit_animation_finished",
		[next_method_name],
		CONNECT_ONESHOT
	)
	_tween.start()

func _on_exit_animation_finished(next_method_name):
	# Llamamos al método que cambia de escena / sale del juego
	call_deferred(next_method_name)

# =====================
# ANIMACIONES DE HOVER Y CLICK
# =====================

# Hover: oscurecer un poco y micro-zoom
func _on_button_mouse_entered(button):
	_tween.interpolate_property(
		button, "modulate",
		button.modulate,
		COLOR_HOVER,
		0.08,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	_tween.interpolate_property(
		button, "rect_scale",
		button.rect_scale,
		Vector2(1.05, 1.05),
		0.08,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
	_tween.start()

func _on_button_mouse_exited(button):
	_tween.interpolate_property(
		button, "modulate",
		button.modulate,
		COLOR_NORMAL,
		0.10,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	_tween.interpolate_property(
		button, "rect_scale",
		button.rect_scale,
		Vector2.ONE,
		0.10,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
	_tween.start()

# Click: se hace grande y se encoge rápido
func _on_button_pressed_anim(button):
	_tween.interpolate_property(
		button, "rect_scale",
		button.rect_scale,
		Vector2(1.1, 1.1),
		0.06,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	_tween.interpolate_property(
		button, "rect_scale",
		Vector2(1.1, 1.1),
		Vector2(1.0, 1.0),
		0.10,
		Tween.TRANS_SINE,
		Tween.EASE_IN,
		0.06
	)
	_tween.start()


