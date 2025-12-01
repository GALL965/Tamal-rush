extends CanvasLayer

onready var _anim = $AnimationPlayer
onready var _rect = $ColorRect
var _next_scene_path = ""

func _ready():

	_rect.modulate.a = 0.0


	if not _anim.is_connected("animation_finished", self, "_on_AnimationPlayer_animation_finished"):
		_anim.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func goto_scene(scene_path):
	_next_scene_path = scene_path

	_anim.play("fade in")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade in":

		get_tree().change_scene(_next_scene_path)
		yield(get_tree(), "idle_frame")

		_anim.play("fade out")
	elif anim_name == "fade out":

		_rect.modulate.a = 0.0
