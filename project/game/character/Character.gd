extends Node2D
class_name Character

signal died
signal spawn_new_enemy
signal damage_player

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


func heal(amount: int):
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
	
	#Block damage with shield
	if type == "regular":
		AudioManager.play_sfx("damage_regular")
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		unblocked_damage = max(damage - shield, 0)
		shield = max(shield - damage, 0)
		hp -= unblocked_damage
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")
	#Block damage with shield
	elif type == "drain":
		AudioManager.play_sfx("damage_drain")
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		unblocked_damage = max(damage - shield, 0)
		shield = max(shield - damage, 0)
		hp -= unblocked_damage
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")

	#Damages both shield and health equally
	elif type == "crushing":
		AudioManager.play_sfx("damage_crushing")
		var had_shield = shield > 0
		# warning-ignore:narrowing_conversion
		shield = max(shield - damage, 0)
		hp -= damage
		unblocked_damage = damage
		
		if had_shield and shield > 0:
			AudioManager.play_sfx("shield_hit")
		elif had_shield:
			AudioManager.play_sfx("shield_breaks")
		
	#Ignores shield and only damages health
	elif type == "piercing":
		AudioManager.play_sfx("damage_piercing")
		hp -= damage
		unblocked_damage = damage
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
	elif pre_shield <= 0 and status_list.has("guard_up"):
		AudioManager.play_sfx("shield_gain")
		shield += status_list.guard_up.amount
	elif unblocked_damage > 0 and status_list.has("rage"):
		add_status("perm_strength", status_list.rage.amount, true, {})
	
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
			var func_state = self.callv(f_name, [status])
			if func_state and func_state.is_valid():
				emit = true
				yield(self, "status_effect_completed")
	if emit:
		emit_signal("finished_updating_status")

#STATUS METHODS

func on_death_divider(_args):
	var status = get_status("divider")
	emit_signal("spawn_new_enemy", self, status.extra_args.enemy)
	emit_signal("spawn_new_enemy", self, status.extra_args.enemy)

func on_death_revenge(_args):
	var status = get_status("revenge")
	emit_signal("damage_player", self, status.amount, "regular")

func start_turn_shield():
	shield = 0

func start_turn_evasion(_args):
	remove_status("evasion")

func start_turn_retaliate(_args):
	remove_status("retaliate")

func start_turn_dodge(_args):
	remove_status("dodge")

func start_turn_poison(_args):
	var status = get_status("poison")
	take_damage(self, status.amount, "poison")
	status.amount -= 1
	if status.amount <= 0:
		remove_status("poison")
