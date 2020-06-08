extends Control

signal closed

var room
var player

func setup(_room, _player):
	room = _room
	player = _player

func reset_room():
	room.reset()

func _on_HealButton_pressed():
	reset_room()
	emit_signal("closed")


func _on_HintButton_pressed():
	reset_room()
	emit_signal("closed")


func _on_BackButton_pressed():
	emit_signal("closed")
