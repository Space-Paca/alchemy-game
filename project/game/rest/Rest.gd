extends Control

signal closed

const REST_HEAL = 70

var room
var player

func setup(_room, _player):
	room = _room
	player = _player

func reset_room():
	room.reset()

func _on_HealButton_pressed():
	AudioManager.play_sfx("heal")
	player.hp = min(player.hp + REST_HEAL, player.max_hp)
	reset_room()
	emit_signal("closed")


func _on_HintButton_pressed():
	reset_room()
	emit_signal("closed")


func _on_BackButton_pressed():
	emit_signal("closed")
