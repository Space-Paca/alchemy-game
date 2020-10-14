extends Node2D
class_name Character

const WEAK_THRESHOLD = 10
const STRONG_THRESHOLD = 20

signal died
# warning-ignore:unused_signal
signal stun
signal remove_attack
signal spawn_new_enemy
signal add_status_all_enemies
signal damage_player
signal freeze_hand
signal restrict

var max_hp : int
var hp : int
var shield : int
var status_list : Dictionary
var char_name: String 


func init(_name: String, _max_hp: int):
	char_name = _name
	max_hp = _max_hp
	hp = max_hp
	shield = 0

func set_max_hp(value):
	max_hp = value

func full_heal():
	hp = max_hp

func heal(amount: int):
	if get_status("deep_wound"):
		return 0
	AudioManager.play_sfx("heal")
	var old_hp = hp
	# warning-ignore:narrowing_conversion
	hp = min(hp + amount, max_hp)
	
	return hp - old_hp

func get_damage_modifiers():
	var mod = 0
	if get_status("temp_strength"):
		mod += get_status("temp_strength").amount
	if get_status("perm_strength"):
		mod += get_status("perm_strength").amount
	return mod

func damage_strength(damage):
	if damage < WEAK_THRESHOLD:
		return "weak"
	elif damage < STRONG_THRESHOLD:
		return "strong"
	else:
		return "stronger"
	

func take_damage(source: Character, damage: int, type: String, retaliate := true):
	if hp <= 0:
		return 0
	
	var pre_shield = shield
	var unblocked_damage
	
	#Check for retaliate
	if retaliate and type != "poison" and source != self and status_list.has("retaliate"):
		source.take_damage(self, status_list["retaliate"].amount, "regular", false)
	
	#Check for evasion
	if status_list.has("evasion"):
		randomize()
		if randf() >= .5:
			AudioManager.play_sfx("dodge")
			status_list["evasion"].amount -= 1
			unblocked_damage = 0
			if status_list["evasion"].amount <= 0:
				remove_status("evasion")
			return unblocked_damage
	
	#Check for dodge
	if status_list.has("dodge"):
		AudioManager.play_sfx("dodge")
		status_list["dodge"].amount -= 1
		unblocked_damage = 0
		if status_list["dodge"].amount <= 0:
			remove_status("dodge")
		return unblocked_damage
	
	#Check for divine protection
	if status_list.has("divine_protection"):
		var status = status_list["divine_protection"]
		if damage > status.amount:
			AudioManager.play_sfx("divine_protected")
# warning-ignore:narrowing_conversion
		damage = min(status.amount, damage)
		status.amount -= damage
	
	#Block damage with shield
	if type == "regular":
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		unblocked_damage = max(damage - shield, 0)
		shield = max(shield - damage, 0)
		hp -= unblocked_damage
		
		AudioManager.play_sfx("damage_regular_" + damage_strength(unblocked_damage))
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")
	#Block damage with shield
	elif type == "drain":
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		unblocked_damage = max(damage - shield, 0)
		shield = max(shield - damage, 0)
		hp -= unblocked_damage
		
		if unblocked_damage > 0:
			AudioManager.play_sfx("damage_drain")
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")

	#Damages both shield and health equally
	elif type == "crushing":
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		shield = max(shield - damage, 0)
		hp -= damage
		unblocked_damage = damage
		AudioManager.play_sfx("damage_crushing_" + damage_strength(unblocked_damage))
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")
		
	#Ignores shield and only damages health
	elif type == "piercing":
		hp -= damage
		unblocked_damage = damage
		AudioManager.play_sfx("damage_piercing_" + damage_strength(unblocked_damage))
	
	#Regular damage, but unblocked damage turns into poison
	elif type == "venom":
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		unblocked_damage = max(damage - shield, 0)
		shield = max(shield - damage, 0)
		
		if unblocked_damage > 0:
			self.add_status("poison", unblocked_damage, false, {})
			AudioManager.play_sfx("damage_poison")
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")
	
	#Ignores shield and only damages health
	elif type == "poison":
		AudioManager.play_sfx("damage_poison")
		hp -= damage
		unblocked_damage = damage
	
	else:
		push_error("Not a valid type of attack: " + str(type))
		assert(false)
	
	if hp <= 0:
		hp = 0
		die()
	else:
		if pre_shield <= 0 and damage > 0 and status_list.has("arcane_aegis"):
			AudioManager.play_sfx("shield_gain")
			shield += status_list.arcane_aegis.amount
		if unblocked_damage > 0 and status_list.has("enrage"):
			add_status("perm_strength", status_list.enrage.amount, true, {})
		if unblocked_damage > 0 and status_list.has("concentration"):
			reduce_status("concentration", unblocked_damage)
			if not status_list.has("concentration"):
				emit_signal("remove_attack")
	
	return unblocked_damage

func gain_shield(value):
	AudioManager.play_sfx("shield_gain")
	shield += value

func die():
	emit_signal("died", self)

#STATUS FUNCS

func get_status(status: String):
	if status_list.has(status):
		return status_list[status]

func add_status(status: String, amount: int, positive: bool, extra_args: Dictionary):
	if AudioManager.has_sfx("status_"+status):
		AudioManager.play_sfx("status_"+status)
	else:
		if positive:
			AudioManager.play_sfx("buff")
		else:
			AudioManager.play_sfx("debuff")
	
	if status == "poison" and get_status("poison_immunity"):
		return
	
	if status_list.has(status):
		status_list[status].amount += amount
	else:
		status_list[status] = {"amount": amount, "positive": positive, "extra_args": extra_args}

func reduce_status(status: String, amount: int):
	if status_list.has(status):
		status_list[status].amount -= amount
		if status_list[status].amount <= 0:
			remove_status(status)

func remove_status(status: String):
	if get_status(status):
		var f_name = "on_remove_" + status
		if self.has_method(f_name):
			self.callv(f_name, [])
	var _err = status_list.erase(status)

func clear_status():
	status_list.clear()

func update_status(type: String):
	var emit = false
	
	#Shield methods
	var f_name = type + "_shield"
	if self.has_method(f_name):
		self.callv(f_name, [])
		
	#Other status methods
	for status in status_list:
		f_name = type + "_"+ str(status)
		if self.has_method(f_name):
			var func_state = self.callv(f_name, [])
			if func_state and func_state.is_valid():
				emit = true
				yield(self, "status_effect_completed")
	if emit:
		emit_signal("finished_updating_status")

#STATUS METHODS

func on_ally_died_avenge():
	var status = get_status("avenge")
	add_status("perm_strength", status.amount, true, {})

func on_death_splitting():
	var status = get_status("splitting")
	emit_signal("spawn_new_enemy", self, status.extra_args.enemy)
	emit_signal("spawn_new_enemy", self, status.extra_args.enemy)

func on_death_martyr():
	var status = get_status("martyr")
	emit_signal("add_status_all_enemies", "perm_strength", status.amount, true)

func on_death_revenge():
	var status = get_status("revenge")
	emit_signal("damage_player", self, status.amount, "regular")

func on_remove_doomsday():
	add_status("perm_strength", 999, true, {})

func start_turn_shield():
	if not get_status("tough"):
		shield = 0

func start_turn_freeze():
	var status = get_status("freeze")
	emit_signal("freeze_hand", status.amount)

func start_turn_restrict_minor():
	var status = get_status("restrict_minor")
	emit_signal("restrict", status.amount, "minor")

func start_turn_restrict_major():
	var status = get_status("restrict_major")
	emit_signal("restrict", status.amount, "major")

func start_turn_evasion():
	remove_status("evasion")

func start_turn_retaliate():
	remove_status("retaliate")

func start_turn_dodge():
	remove_status("dodge")

func start_turn_concentration():
	remove_status("concentration")

func start_turn_divine_protection():
	var status = get_status("divine_protection")
	#Resets each turn
	status.amount = status.extra_args.value

func end_turn_poison():
	var status = get_status("poison")
	take_damage(self, status.amount, "poison")
	status.amount -= 1
	if status.amount <= 0:
		remove_status("poison")

func end_turn_freeze():
	remove_status("freeze")


func end_turn_restrained():
	remove_status("restrain")

func end_turn_restrict_minor():
	remove_status("restrict_minor")

func end_turn_restrict_major():
	remove_status("restrict_major")

func end_turn_weak():
	var status = get_status("weakness")
	status.amount -= 1
	if status.amount <= 0:
		remove_status("weakness")

func end_turn_time_bomb():
	remove_status("time_bomb")

func end_turn_burn():
	remove_status("burning")
