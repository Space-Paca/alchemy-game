extends Node2D

var attempts

onready var label = $BG/Label

func set_attempts(value):
	attempts = value
	update_text()

func decrease_attempts():
	attempts -= 1
	update_text()

func blink_red():
	$AnimationPlayer.play("blink_red")

func get_attempts():
	return attempts

func update_text():
	label.text = str(attempts)
