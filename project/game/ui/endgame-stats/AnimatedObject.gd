extends Control

signal animation_finished

export var fade_in_dur = .8

var skip := false
var animation_active := false
var anim_tween : Tween

func enter_animation(s: bool):
	animation_active = true
	skip = s
	if not skip:
		anim_tween = Tween.new()
		add_child(anim_tween)
		
# warning-ignore:return_value_discarded
		anim_tween.interpolate_property(self, "modulate:a", 0, 1, fade_in_dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
# warning-ignore:return_value_discarded
		anim_tween.start()
		yield(anim_tween, "tween_completed")
	else:
		modulate.a = 1.0
	
	if not skip:
		emit_signal("animation_finished")
		animation_active = false

func skip_animation():
	skip = true
	if anim_tween and is_instance_valid(anim_tween) and anim_tween.is_active():
# warning-ignore:return_value_discarded
		anim_tween.seek(fade_in_dur)
		emit_signal("animation_finished")
		
	animation_active = false
