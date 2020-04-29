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
	AudioManager.play_sfx("combine_fail")
	damage_all(20, "regular")

func add_status(targeting: String, status: String, amount: int, positive: bool):
	if targeting == "self":
		player.add_status(status, amount, positive)
	elif targeting == "enemy":
		var func_state = (require_target() as GDScriptFunctionState)
		if func_state and func_state.is_valid():
			yield(self, "target_set")
			target.add_status(status, amount, positive)
	else:
		push_error("Not a valid target: " + str(targeting))
		assert(false)
	
	
	resolve()


func damage(amount: int, type: String):
	var func_state = (require_target() as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(self, "target_set")
	
	target.take_damage(player, amount, type)
	resolve()


func damage_all(amount: int, type: String):
	for enemy in enemies.duplicate():
		(enemy as Enemy).take_damage(player, amount, type)
		yield(get_tree().create_timer(.35),"timeout")
	
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
