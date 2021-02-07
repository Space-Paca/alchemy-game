extends CanvasLayer

signal transition_finished

onready var transition_texture = $TransitionTexture
onready var tween = $Tween

const DURATION_2 = .5

var active = false
var material : ShaderMaterial

func _ready():
	randomize()
	material = transition_texture.material


func randomize_direction():
	for par in ["mirror_x", "mirror_y"]:
		material.set_shader_param(par, randi() % 2)


func invert_direction():
	for par in ["mirror_x", "mirror_y"]:
		material.set_shader_param(par, !material.get_shader_param(par))


func transition_to(scene_path: String):
	randomize_direction()
	active = true
	transition_texture.show()
	tween.interpolate_property(material, "shader_param/value", 0, 1, DURATION_2)
	tween.start()
	
	yield(tween, "tween_completed")
# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path)
	invert_direction()
	
	tween.interpolate_property(material, "shader_param/value", 1, 0, DURATION_2)
	tween.start()
	
	yield(tween, "tween_completed")
	active = false
	transition_texture.hide()
	
	emit_signal("transition_finished")
