extends Node2D
class_name Character

signal died

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
	# warning-ignore:narrowing_conversion
	hp = min(hp + amount, max_hp)

func get_damage_modifiers():
	var mod = 0
	if get_status("temp_strength"):
		mod += get_status("temp_strength").amount
		remove_status("temp_strength")
	if get_status("perm_strength"):
		mod += get_status("perm_strength").amount
	return mod

func take_damage(source: Character, damage: int, type: String):
	if hp <= 0:
		return
	
	var unblocked_damage
	damage += source.get_damage_modifiers()
	
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
	elif type == "pierce":
		AudioManager.play_sfx("damage_pierce")
		hp -= damage
		unblocked_damage = damage
	
	else:
		push_error("Not a valid type of attack: " + str(type))
		assert(false)
	
	if hp <= 0:
		hp = 0
		die()
	return unblocked_damage


func gain_shield(value):
	AudioManager.play_sfx("shield_gain")
	shield += value

#STATUS FUNCS

func get_status(status: String):
	if status_list.has(status):
		return status_list[status]

func add_status(status: String, amount: int, positive: bool):
	if positive:
		AudioManager.play_sfx("buff")
	else:
		AudioManager.play_sfx("debuff")

	if status_list.has(status):
		status_list[status].amount += amount
	else:
		status_list[status] = {"amount": amount, "positive": positive}

func remove_status(status: String):
	var _err = status_list.erase(status)

func clear_status():
	status_list.clear()

func update_status():
	shield = 0
	for status in status_list:
		var f_name = "update_"+ str(status)
		if self.has_method(f_name):
			self.callv(f_name, [status])

func update_dodge(_args):
	remove_status("dodge")

func update_poison(_args):
	var status = get_status("poison")
	take_damage(self, status.amount, "pierce")
	status.amount -= 1
	if status.amount <= 0:
		remove_status("poison")
	

func die():
	emit_signal("died", self)
