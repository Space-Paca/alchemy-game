extends Control

signal closed

func _ready():
	pass # Replace with function body.

func _on_HealButton_pressed():
	emit_signal("closed")


func _on_HintButton_pressed():
	emit_signal("closed")
