extends Control

signal animation_finished

export var fade_in_duration := .3

func _ready():
	modulate.a = 0


func animate():
	var t = Tween.new()
	add_child(t)
	t.interpolate_property(self, "modulate:a", 0, 1, fade_in_duration)
	t.start()
	yield(t, "tween_completed")
	
	for child in get_children():
		if child.has_method("animate"):
			child.animate()
			yield(child, "animation_finished")
	
	emit_signal("animation_finished")
	t.queue_free()
