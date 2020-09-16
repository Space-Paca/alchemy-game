extends Control

signal closed

var map_node : MapNode
var player
var artifact_rarity

func setup(node, _player, level):
	map_node = node
	player = _player
	match level:
		1:
			artifact_rarity =  "common"
		2:
			artifact_rarity =  "uncommon"
		3:
			artifact_rarity =  "rare"
		_:
			assert(false, "Not a valid floor level number: " + str(level))

func reset_room():
	map_node.set_type(MapNode.EMPTY)

func _on_BackButton_pressed():
	reset_room()
	emit_signal("closed")
