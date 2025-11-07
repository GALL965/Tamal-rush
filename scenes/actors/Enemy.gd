extends KinematicBody2D

export var patrol_speed := 50.0
export var chase_speed  := 90.0
export var detect_range := 160.0
onready var vis := $Vis


export (NodePath) var animated_sprite_path = NodePath("AnimatedSprite")

const SAFE_MARGIN := 24.0

var vel := Vector2.ZERO
var target_dir := Vector2.ZERO
var player: Node = null
var chasing := false
var facing := 1

onready var anim: AnimatedSprite = null
onready var wander := $Wander

func _ready():
	add_to_group("enemies")
	set_physics_process(true)


	_set_anim_ref()


	var ps = get_tree().get_nodes_in_group("player")
	if ps.size() > 0:
		player = ps[0]

	_set_random_dir()
	if wander: wander.start(rand_range(0.8, 1.6))
	
	if vis:
		vis.connect("screen_exited", self, "_on_screen_exited")
		vis.connect("screen_entered", self, "_on_screen_entered")

func _physics_process(delta):
	if player == null:
		var ps = get_tree().get_nodes_in_group("player")
		if ps.size() > 0:
			player = ps[0]

	var away := global_position - Game.run_start_camp_pos
	var dist_camp := away.length()
	var inside_camp := dist_camp < (Game.camp_safe_radius + SAFE_MARGIN)

	var player_in_camp := false
	if player:
		player_in_camp = player.global_position.distance_to(Game.run_start_camp_pos) < Game.camp_safe_radius

	if inside_camp:
		var dir := away
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT
		target_dir = dir.normalized()
		chasing = false
		vel = target_dir * max(patrol_speed, chase_speed) * 1.15
	else:
		var df := Game.distance_factor(global_position)
		var sp_patrol := patrol_speed * (1.0 + 0.05 * (df - 1.0))
		var sp_chase  := chase_speed  * (1.0 + 0.10 * (df - 1.0))

		if player:
			var dist_to_player := global_position.distance_to(player.global_position)
			chasing = (not player_in_camp) and (dist_to_player <= detect_range) and (not player.is_hidden())
			if chasing:
				target_dir = (player.global_position - global_position).normalized()
				vel = target_dir * sp_chase
			else:
				if target_dir == Vector2.ZERO:
					_set_random_dir()
				vel = target_dir * sp_patrol
		else:
			if target_dir == Vector2.ZERO:
				_set_random_dir()
			vel = target_dir * patrol_speed

	vel = move_and_slide(vel)
	_update_anim()

func _on_Wander_timeout():
	if not chasing and global_position.distance_to(Game.run_start_camp_pos) > (Game.camp_safe_radius + SAFE_MARGIN):
		_set_random_dir()
	if wander: wander.start(rand_range(0.8, 1.8))

func _set_random_dir():
	target_dir = Vector2(randf()*2.0 - 1.0, randf()*2.0 - 1.0).normalized()


func _set_anim_ref():

	if animated_sprite_path != NodePath(""):
		anim = get_node_or_null(animated_sprite_path)

	if anim == null:
		anim = _find_animated_sprite(self)

	if anim == null:
		push_warning("Enemy: AnimatedSprite no encontrado. Asigna 'animated_sprite_path' o renombra el nodo.")
	else:

		anim.play("idle")

func _find_animated_sprite(n: Node) -> AnimatedSprite:
	for c in n.get_children():
		if c is AnimatedSprite:
			return c
		var r = _find_animated_sprite(c)
		if r != null:
			return r
	return null

func _update_anim():
	if anim == null:
		return 
		

	if abs(vel.x) > 0.1:
		if vel.x >= 0.0:
			facing = 1
		else:
			facing = -1
	anim.flip_h = (facing < 0)


	var speed := vel.length()
	var want := "idle"
	if chasing and speed > 5.0:
		want = "run"
	elif speed > 5.0:
		want = "walk"


	if want == "walk":
		anim.speed_scale = clamp(speed / max(patrol_speed, 0.001), 0.6, 1.3)
	elif want == "run":
		anim.speed_scale = clamp(speed / max(chase_speed, 0.001), 0.8, 1.4)
	else:
		anim.speed_scale = 1.0

	if anim.animation != want:
		anim.play(want)
