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
	if enemies.size() == 1:
		target = enemies[0]
		return
	
	for enemy in enemies:
		enemy.set_button_disabled(false)
	
	yield(self, "target_set")
	for enemy in enemies:
		enemy.set_button_disabled(true)


func combination_failure():
	damage_all(10)


func damage(amount: int):
	var func_state = (require_target() as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(self, "target_set")
	
	target.take_damage(amount)
	resolve()


func damage_all(amount: int):
	for enemy in enemies.duplicate():
		(enemy as Enemy).take_damage(amount)
	
	resolve()


func shield(amount: int):
	player.gain_shield(amount)
	
	resolve()


func heal(amount: int):
	player.heal(amount)
	
	resolve()


func _on_enemy_selected(enemy: Enemy):
	target = enemy
	emit_signal("target_set")
