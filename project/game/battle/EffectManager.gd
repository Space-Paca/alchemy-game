extends Node

signal effect_resolved
signal target_required

var enemies : Array
var player : Player


func setup(_player: Player, _enemies: Array):
	player = _player
	enemies = _enemies


func get_target() -> Character:
	return enemies[0]


func combination_failure():
	pass


func damage(amount: int):
	pass


func damage_all(amount: int):
	for enemy in enemies:
		(enemy as Character).take_damage(amount)


func shield(amount: int):
	pass


func cure(amount: int):
	pass
