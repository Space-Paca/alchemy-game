extends Node

signal effect_resolved
signal failure_resolved
signal target_set

const TARGETED_EFFECTS := ["reduce_status", "add_status", "damage"]

var enemies : Array
var player : Player
var target : Enemy


func setup(_player: Player):
	player = _player
	enemies = []


func add_enemy(enemy : Enemy):
	enemies.append(enemy)
	# warning-ignore:return_value_discarded
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


func combination_failure(reagent_list, grid):
	for reagent in reagent_list:
		var effect = ReagentDB.get_from_name(reagent.type).effect
		var value = effect.value if not reagent.upgraded else effect.upgraded_value
		if reagent.type != "trash":
			grid.remove_reagent(reagent)
			
		if effect.type == "damage":
			damage_random(value, "regular")
		elif effect.type == "damage_all":
			damage_all(value, "regular")
		elif effect.type == "damage_self":
			damage_self(value, "regular")
		elif effect.type == "shield":
			shield(value)
		elif effect.type == "heal":
			heal(value)
		elif effect.type == "status":
			add_status_random(effect.status_type, value, effect.positive)
		yield(self, "effect_resolved")
		
		if reagent.type == "trash":
			grid.destroy_reagent(reagent.type)

			
	
	emit_signal("failure_resolved")


#Gives a status to a random enemy
func add_status_random(status: String, amount: int, positive: bool):
	var possible_enemies = enemies.duplicate()
	randomize()
	possible_enemies.shuffle()
	for enemy in possible_enemies:
		if enemy.hp > 0:
			enemy.add_status(status, amount, positive)
			yield(get_tree().create_timer(.5), "timeout")
			break

	resolve()


func reduce_status(targeting: String, status: String, amount: int):
	AudioManager.play_sfx("debuff_denied")
	if targeting == "self":
		player.reduce_status(status, amount)
	elif targeting == "enemy":
		var func_state = (require_target() as GDScriptFunctionState)
		if func_state and func_state.is_valid():
			yield(self, "target_set")
		target.reduce_status(status, amount)
		yield(get_tree().create_timer(.5), "timeout")
	else:
		push_error("Not a valid target: " + str(targeting))
		assert(false)
	
	resolve()


func add_status(targeting: String, status: String, amount: int, positive: bool):
	if targeting == "self":
		player.add_status(status, amount, positive)
		yield(get_tree().create_timer(.5), "timeout")
	elif targeting == "enemy":
		var func_state = (require_target() as GDScriptFunctionState)
		if func_state and func_state.is_valid():
			yield(self, "target_set")
		target.add_status(status, amount, positive)
		yield(get_tree().create_timer(.5), "timeout")
	else:
		push_error("Not a valid target: " + str(targeting))
		assert(false)
	
	resolve()


#Damage a random enemy
func damage_random(amount: int, type: String):
	var possible_enemies = enemies.duplicate()
	randomize()
	possible_enemies.shuffle()
	for enemy in possible_enemies:
		if enemy.hp > 0:
			var func_state = enemy.take_damage(player, amount, type)
			if func_state and func_state.is_valid():
				yield(enemy, "resolved")
			else:
				yield(get_tree().create_timer(.5), "timeout")
			break
	
	resolve()

func damage_self(amount: int, type: String):	
	var func_state = player.take_damage(player, amount, type)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	resolve()

func damage(amount: int, type: String):
	var func_state = (require_target() as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(self, "target_set")
	
	func_state = target.take_damage(player, amount, type)
	if func_state and func_state.is_valid():
		yield(target, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	resolve()


func damage_all(amount: int, type: String):
	for enemy in enemies.duplicate():
		var func_state = (enemy as Enemy).take_damage(player, amount, type)
		if func_state and func_state.is_valid():
			yield(enemy, "resolved")
		else:
			yield(get_tree().create_timer(.5), "timeout")
	
	resolve()


func shield(amount: int):
	var func_state = player.gain_shield(amount)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	resolve()


func heal(amount: int):
	var func_state = player.heal(amount)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	resolve()


func _on_enemy_selected(enemy: Enemy):
	target = enemy
	emit_signal("target_set")
