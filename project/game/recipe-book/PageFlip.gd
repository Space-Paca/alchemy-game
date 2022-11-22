extends Node2D

signal animation_ended
signal fade_ended

onready var anim_player = $AnimationPlayer
onready var tween = $Tween

const FADE_DUR = .1

var flipping = false


func _ready():
	modulate.a = 0


func flip_left():
	_flip("flip-to-left")


func flip_right():
	_flip("flip-to-right")


func _flip(anim):
	if anim_player.is_playing():
		return
	flipping = true
	_fade(0, 1)
	yield(tween, "tween_completed")
	emit_signal("fade_ended")
	anim_player.play(anim)


func _fade(from, to):
	tween.interpolate_property(self, "modulate:a", from, to, FADE_DUR)
	tween.start()


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("animation_ended")
	flipping = false
	_fade(1, 0)
