extends Control

signal animation_finished

export var fade_in_duration := .3

var should_skip := false
var animation_active := false
var t : Tween

func _ready():
	modulate.a = 0


func animate(s := false):
	animation_active = true
	should_skip = s
	
	if should_skip:
		modulate.a = 1
	else:
		t = Tween.new()
		add_child(t)
# warning-ignore:return_value_discarded
		t.interpolate_property(self, "modulate:a", 0, 1, fade_in_duration)
# warning-ignore:return_value_discarded
		t.start()
		yield(t, "tween_completed")
#		t.queue_free()
	
	for child in get_children():
		if child.has_method("animate"):
			child.animate(should_skip)
			if not should_skip:
				yield(child, "animation_finished")
	
	if not should_skip:
		emit_signal("animation_finished")
	animation_active = false


func skip():
	should_skip = true
	if t and is_instance_valid(t) and t.is_active():
# warning-ignore:return_value_discarded
		t.seek(fade_in_duration)
	else:
		for child in get_children():
			if child.has_method("animate") and child.animation_active:
				child.skip()
				break
	
	emit_signal("animation_finished")
	animation_active = false
