extends Control

signal closed

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")
const REST_HEAL = 70

var map_node : MapNode
var player
var combinations

func setup(node, _player):
	map_node = node
	player = _player


func reset_room():
	map_node.set_type(MapNode.EMPTY)


func _on_BackButton_pressed():
	emit_signal("closed")
