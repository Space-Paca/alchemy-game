extends Node

var enemies : Array
var player : Player

func setup(_player: Player, _enemies: Array):
	player = _player
	enemies = _enemies


func get_target() -> Character:
	# Replace with target aquirement
	return enemies[0]


func damage(args: Array):
	var target = get_target()
	target.take_damage(args[0])


func damage_all(args: Array):
	for enemy in enemies:
		(enemy as Character).take_damage(args[0])


func shield(args: Array):
	pass


func cure(args: Array):
	pass
