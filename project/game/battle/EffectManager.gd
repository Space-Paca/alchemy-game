extends Node

var enemies : Array
var player : Player

func setup(_player: Player, _enemies: Array):
	player = _player
	enemies = _enemies


func get_target() -> Character:
	# Replace with target aquirement
	return enemies[0]


func damage(amount: int):
	var target = get_target()
	target.take_damage(amount)


func damage_all(amount: int):
	for enemy in enemies:
		(enemy as Character).take_damage(amount)


func shield(amount: int):
	pass


func cure(amount: int):
	pass
