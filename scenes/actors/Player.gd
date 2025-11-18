extends KinematicBody2D

export var move_speed := 200.0
export var dash_speed := 600.0
export var dash_time := 0.50
export var dash_cooldown := 0.6

var vel := Vector2.ZERO
var dash_timer := 0.0
var can_dash := true
var in_bush := false
var hidden := false

onready var dash_cd := $DashCD
onready var anim := $AnimatedSprite  


var facing := 1   
var current_anim := ""

func _ready():
	add_to_group("player")
	set_physics_process(true)

	if not dash_cd.is_connected("timeout", self, "_on_DashCD_timeout"):
		dash_cd.connect("timeout", self, "_on_DashCD_timeout")

func _physics_process(delta):
	var input_dir := Vector2(
		int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		int(Input.is_action_pressed("move_down"))  - int(Input.is_action_pressed("move_up"))
	).normalized()

	var target := input_dir * move_speed

	if dash_timer > 0:
		dash_timer -= delta


	else:

		vel = vel.linear_interpolate(target, 10 * delta)

	if Input.is_action_just_pressed("dash") and can_dash:
		_try_dash(input_dir)


	vel = move_and_slide(vel)

	_update_anim(input_dir)

func _try_dash(input: Vector2) -> void:
	var name_to_spend := _pop_any_carried_tamal()
	if name_to_spend == "":
		return
	can_dash = false
	dash_timer = dash_time
	var dir: Vector2 = input
	if dir == Vector2.ZERO:
		if vel.length() > 0.0:
			dir = vel.normalized()
		else:
			dir = Vector2.RIGHT
	vel = dir * dash_speed
	$dash.play()
	dash_cd.start(dash_cooldown)


	if anim.animation != "dash":
		current_anim = "dash"
		anim.play("dash")




func _on_DashCD_timeout():
	can_dash = true

func _pop_any_carried_tamal() -> String:
	for k in Game.carried.keys():
		var n = Game.carried[k]
		if n > 0:
			Game.carried[k] = n - 1
			if Game.carried[k] <= 0:
				Game.carried.erase(k)
			return k
	return ""


func set_in_bush(state: bool):
	in_bush = state

func is_hidden() -> bool:
	return hidden
	
	
func _update_anim(input: Vector2) -> void:

	if dash_timer > 0.0:

		if abs(input.x) > 0.1:
			facing = sign(input.x)
		anim.flip_h = (facing < 0)

		if anim.animation != "dash":
			current_anim = "dash"
			anim.play("dash")
		return


	var want := "idle"
	if input != Vector2.ZERO or vel.length() > 5.0:
		want = "run"


	if abs(input.x) > 0.1:
		facing = sign(input.x)
	anim.flip_h = (facing < 0)


	var speed_scale := clamp(vel.length() / move_speed, 0.6, 1.4)
	if want == "run":
		anim.speed_scale = speed_scale
	else:
		anim.speed_scale = 1.0

	if want != current_anim:
		current_anim = want
		anim.play(current_anim)

func _die():
	Game.lose_carried()
	can_dash = true
	dash_timer = 0.0
	dash_cd.stop()
	current_anim = ""
	anim.play("idle")
	get_tree().call_group("world", "respawn_player_at_camp")
