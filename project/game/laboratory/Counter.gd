extends Node2D

var attempts

onready var label = $Label

func set_attempts(value):
	attempts = value
	update_text()

func decrease_attempts():
	attempts -= 1
	update_text()

func get_attempts():
	return attempts

func update_text():
	label.text = str(attempts)
