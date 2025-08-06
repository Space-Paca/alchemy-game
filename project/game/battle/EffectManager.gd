extends Node

signal effect_resolved
signal failure_resolved
signal target_set

const TARGETED_EFFECTS := ["reduce_status", "add_status", "multiply_status", "damage", "drain"]

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


func reagent_effect(reagent, effect):
	var value = effect.value if not reagent.upgraded else effect.upgraded_value
	var boost = {
		"all": 0,
		"damage": 0,
		"shield": 0,
		"heal": 0,
		"status": 0,
	}
	
	if (reagent.type == "trash" or reagent.type == "trash_plus") and player.has_artifact("trash_heal"):
		effect.type = "heal"
	if effect.type == "damage":
		damage_random(value, "regular", boost, false, true)
	elif effect.type == "damage_all":
		damage_all(value, "regular", boost, false, true)
	elif effect.type == "damage_piercing":
		damage_random(value, "piercing", boost, false, true)
	elif effect.type == "damage_self":
		damage_self(value, "regular")
	elif effect.type == "shield":
		shield(value, boost, true)
	elif effect.type == "heal":
		heal(value, boost)
	elif effect.type == "status":
		if effect.target == "random_enemy":
			add_status_random(effect.status_type, value, effect.positive, boost, true)
		elif effect.target == "self":
			add_status("self", effect.status_type, value, effect.positive, boost, true)


func combination_failure(reagent_list, grid):
	for reagent in reagent_list:
		if reagent.type != "trash":
			grid.remove_reagent(reagent)
		
		var data = ReagentDB.get_from_name(reagent.type).effect
		if typeof(data)== TYPE_ARRAY:
			for effect in data:
				reagent_effect(reagent, effect)
				yield(self, "effect_resolved")
		else:
			reagent_effect(reagent, data)
			yield(self, "effect_resolved")
		
		if reagent.type == "trash":
			grid.destroy_reagent(reagent.type)
		
		#Check for hex status
		for enemy in enemies.duplicate():
			var status = enemy.get_status("hex")
			if status:
				enemy.add_status("perm_strength", status.amount, true)
				yield(get_tree().create_timer(.5), "timeout")

	emit_signal("failure_resolved")


#Gives a status to a random enemy
func add_status_random(status: String, amount: int, positive: bool, boost_effects:= {"all":0, "status":0}, is_miscombination := false):
	var boost = boost_effects.all + boost_effects.status
	if not is_miscombination and status == "poison" and player.has_artifact("buff_poison"):
		boost += 3
	var possible_enemies = enemies.duplicate()
	randomize()
	possible_enemies.shuffle()
	for enemy in possible_enemies:
		if enemy.hp > 0:
			enemy.add_status(status, amount + boost, positive)
			yield(get_tree().create_timer(.5), "timeout")
			break

	resolve()


func reduce_status(targeting: String, status: String, amount: int, boost_effects:= {"all":0, "status":0}):
	var boost = boost_effects.all + boost_effects.status
	AudioManager.play_sfx("debuff_denied")
	if targeting == "self":
		player.reduce_status(status, amount + boost)
	elif targeting == "enemy":
		var func_state = (require_target() as GDScriptFunctionState)
		if func_state and func_state.is_valid():
			yield(self, "target_set")
		target.reduce_status(status, amount + boost)
		yield(get_tree().create_timer(.5), "timeout")
	else:
		push_error("Not a valid target: " + str(targeting))
		assert(false)
	
	resolve()


func reshuffle(_boost_effects: Dictionary):
	var func_state = player.reshuffle()
	if func_state and func_state.is_valid():
		yield(player, "resolved")

	resolve()


func reshuffle_draw(amount:int, _boost_effects: Dictionary):
	var func_state = player.reshuffle()
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	func_state = player.draw(amount)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	resolve()


func draw(amount:int, _boost_effects: Dictionary):
	var func_state = player.draw(amount)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	resolve()


func add_status_all(status: String, amount: int, positive: bool, boost_effects:= {"all":0, "status":0}, is_miscombination := false):
	var boost = boost_effects.all + boost_effects.status
	if not is_miscombination and status == "poison" and player.has_artifact("buff_poison"):
		boost += 3
	var temp_enemies = enemies.duplicate()
	for enemy in temp_enemies:
			enemy.add_status(status, amount + boost, positive)
			yield(get_tree().create_timer(.3), "timeout")
	resolve()


func multiply_status(targeting: String, status: String, amount: float, positive: bool, boost_effects:= {"all":0, "status":0}, is_miscombination := false):
	var boost = boost_effects.all + boost_effects.status
	if not is_miscombination and status == "poison" and player.has_artifact("buff_poison"):
		boost += 3
	if targeting == "self":
		player.multiply_status(status, amount, positive)
		if boost:
			player.add_status(status, boost, positive)
		yield(get_tree().create_timer(.5), "timeout")
	elif targeting == "enemy":
		var func_state = (require_target() as GDScriptFunctionState)
		if func_state and func_state.is_valid():
			yield(self, "target_set")
		target.multiply_status(status, amount, positive)
		if boost:
			target.add_status(status, boost, positive)
		yield(get_tree().create_timer(.5), "timeout")
	else:
		push_error("Not a valid target: " + str(targeting))
		assert(false)
	resolve()


func add_status(targeting: String, status: String, amount: int, positive: bool, boost_effects:= {"all":0, "status":0}, is_miscombination := false):
	var boost = boost_effects.all + boost_effects.status
	if not is_miscombination and status == "poison" and player.has_artifact("buff_poison"):
		boost += 3
	if targeting == "self":
		player.add_status(status, amount + boost, positive)
		yield(get_tree().create_timer(.5), "timeout")
	elif targeting == "enemy":
		var func_state = (require_target() as GDScriptFunctionState)
		if func_state and func_state.is_valid():
			yield(self, "target_set")
		target.add_status(status, amount + boost, positive)
		yield(get_tree().create_timer(.5), "timeout")
	else:
		push_error("Not a valid target: " + str(targeting))
		assert(false)
	resolve()

#Damage a random enemy
func damage_random(amount: int, type: String, boost_effects:= {"all":0, "damage":0}, use_damage_mod := true, _is_miscombination := false):
	ShakeCam.shake(.2, ShakeCam.ENEMY_HIT)
	var possible_enemies = enemies.duplicate()
	var boost = boost_effects.all + boost_effects.damage
	boost = boost if not use_damage_mod else boost + player.get_damage_modifiers()
# warning-ignore:narrowing_conversion
	amount = max(0, amount + boost)
	randomize()
	possible_enemies.shuffle()
	for enemy in possible_enemies:
		if enemy.hp > 0:
			player.increase_stat("damage_dealt", amount)
			var func_state = enemy.take_damage(player, amount, type)
			if func_state and func_state.is_valid():
				yield(enemy, "resolved")
			else:
				yield(get_tree().create_timer(.5), "timeout")
			break
	resolve()


func damage_self(amount: int, type: String, _boost_effects:= {}):
	ShakeCam.shake(.2, ShakeCam.PLAYER_HIT)
	var func_state = player.take_damage(player, amount, type)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	resolve()


func damage(amount: int, type: String, boost_effects:= {"all":0, "damage":0}, use_damage_mod := true, _is_miscombination := false):
	var func_state = (require_target() as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(self, "target_set")
	ShakeCam.shake(.2, ShakeCam.ENEMY_HIT)
	var boost = boost_effects.damage + boost_effects.all
	boost = boost if not use_damage_mod else boost + player.get_damage_modifiers()
# warning-ignore:narrowing_conversion
	amount = max(0, amount + boost)
	player.increase_stat("damage_dealt", amount)
	func_state = target.take_damage(player, amount, type)
	if func_state and func_state.is_valid():
		yield(target, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	resolve()


func drain(amount: int, boost_effects:= {"all":0, "damage":0, "heal":0}, use_damage_mod := true, _is_miscombination := false):
	var func_state = (require_target() as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(self, "target_set")
	ShakeCam.shake(.3, ShakeCam.ENEMY_HIT)
	var boost = boost_effects.damage + boost_effects.heal + boost_effects.all
	boost = boost if not use_damage_mod else boost + player.get_damage_modifiers()
# warning-ignore:narrowing_conversion
	amount = max(0, amount + boost)
	player.increase_stat("damage_dealt", amount)
	func_state = target.drain(player, amount)
	if func_state and func_state.is_valid():
		yield(target, "resolved")
	else:
		yield(get_tree().create_timer(.3), "timeout")
	
	resolve()


func damage_all(amount: int, type: String, boost_effects:= {"all":0, "damage":0}, use_damage_mod := true, _is_miscombination := false):
	ShakeCam.shake(.5, ShakeCam.ENEMY_HIT)
	var boost = boost_effects.damage + boost_effects.all
	boost = boost if not use_damage_mod else boost + player.get_damage_modifiers()
# warning-ignore:narrowing_conversion
	amount = max(0, amount + boost)
	var temp_enemies = enemies.duplicate()
	for enemy in temp_enemies:
		player.increase_stat("damage_dealt", amount)
		var func_state = (enemy as Enemy).take_damage(player, amount, type)
		if func_state and func_state.is_valid():
			yield(enemy, "resolved")
		else:
			yield(get_tree().create_timer(.3), "timeout")
	
	resolve()


func shield(amount: int, boost_effects:= {"all":0, "shield":0}, is_miscombination := false):
	var boost = boost_effects.all + boost_effects.shield
	if not is_miscombination:
		if player.has_artifact("buff_shield"):
			amount += 2
		if player.has_artifact("buff_shield_plus"):
			amount += 8
		
	var func_state = player.gain_shield(amount + boost)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	resolve()


func shield_heal(shield_mult: float, shield_reduction: float, boost_effects:= {"all":0, "damage":0}):
	var boost = boost_effects.all + boost_effects.heal
	var amount = max(0, player.shield*shield_mult + boost)
	var func_state = player.heal(amount + boost)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	if shield_reduction > 0:
# warning-ignore:narrowing_conversion
		func_state = player.lose_shield(ceil(player.shield*shield_reduction))
		if func_state and func_state.is_valid():
			yield(player, "resolved")
		else:
			yield(get_tree().create_timer(.5), "timeout")
	resolve()


func shield_bash(shield_mult: float, shield_reduction: float, type: String, boost_effects:= {"all":0, "damage":0}, use_damage_mod := true):
	var func_state = (require_target() as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(self, "target_set")
	ShakeCam.shake(.2, ShakeCam.ENEMY_HIT)
	var boost = boost_effects.damage + boost_effects.all
	boost = boost if not use_damage_mod else boost + player.get_damage_modifiers()
# warning-ignore:narrowing_conversion
	var amount = max(0, player.shield*shield_mult + boost)
	player.increase_stat("damage_dealt", amount)
	func_state = target.take_damage(player, amount, type)
	if func_state and func_state.is_valid():
		yield(target, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	
	if shield_reduction > 0:
		func_state = player.lose_shield(ceil(player.shield*shield_reduction))
		if func_state and func_state.is_valid():
			yield(player, "resolved")
		else:
			yield(get_tree().create_timer(.5), "timeout")
	resolve()


func shield_bash_all(shield_mult: float, shield_reduction: float, type: String, boost_effects:= {"all":0, "damage":0}, use_damage_mod := true):
	ShakeCam.shake(.5, ShakeCam.ENEMY_HIT)
	var boost = boost_effects.damage + boost_effects.all
	boost = boost if not use_damage_mod else boost + player.get_damage_modifiers()
# warning-ignore:narrowing_conversion
	var amount = max(0, player.shield*shield_mult + boost)
	var temp_enemies = enemies.duplicate()
	for enemy in temp_enemies:
		player.increase_stat("damage_dealt", amount)
		var func_state = (enemy as Enemy).take_damage(player, amount, type)
		if func_state and func_state.is_valid():
			yield(enemy, "resolved")
		else:
			yield(get_tree().create_timer(.3), "timeout")
	
	if shield_reduction > 0:
		var func_state = player.lose_shield(ceil(player.shield*shield_reduction))
		if func_state and func_state.is_valid():
			yield(player, "resolved")
		else:
			yield(get_tree().create_timer(.5), "timeout")
	resolve()


func heal(amount: int, boost_effects:= {"all":0, "heal":0}):
	var boost = boost_effects.all + boost_effects.heal
	var func_state = player.heal(amount+ boost)
	if func_state and func_state.is_valid():
		yield(player, "resolved")
	else:
		yield(get_tree().create_timer(.5), "timeout")
	resolve()


func _on_enemy_selected(enemy: Enemy):
	target = enemy
	emit_signal("target_set")
