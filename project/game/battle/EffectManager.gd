extends Node

signal effect_resolved
signal target_set

var enemies : Array
var player : Player
var target : Enemy


func setup(_player: Player, _enemies: Array):
	player = _player
	enemies = _enemies
	for enemy in enemies:
		enemy.connect("selected", self, "_on_enemy_selected")


func remove_enemy(enemy: Enemy):
	enemies.erase(enemy)


func resolve():
	yield(get_tree(), "physics_frame")
	emit_signal("effect_resolved")


func require_target():
	for enemy in enemies:
		enemy.set_button_disabled(false)
	
	yield(self, "target_set")
	for enemy in enemies:
		enemy.set_button_disabled(true)


func combination_failure():
	damage_all(5)


func damage(amount: int):
	require_target()
	yield(self, "target_set")
	
	target.take_damage(amount)
	resolve()


func damage_all(amount: int):
	for enemy in enemies:
		(enemy as Enemy).take_damage(amount)
	
	resolve()


func shield(amount: int):
	pass


func cure(amount: int):
	pass


func _on_enemy_selected(enemy: Enemy):
	target = enemy
	emit_signal("target_set")
