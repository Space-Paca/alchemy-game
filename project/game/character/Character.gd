extends Node
class_name Character

signal died

var max_hp : int
var hp : int
var shield : int
var char_name: String 


func init(_name: String, _max_hp: int):
	char_name = _name
	max_hp = _max_hp
	hp = max_hp
	shield = 0


func heal(amount):
	hp = min(hp + amount, max_hp)


func take_damage(damage: int, type: String):
	
	#Block damage with shield
	if type == "regular":
		var unblocked_damage = max(damage - shield, 0)
		shield = max(shield - damage, 0)
		hp -= unblocked_damage
	#Damages both shield and health equally
	elif type == "pierce":
		shield = max(shield - damage, 0)
		hp -= damage
	#Ignores shield and only damages health
	elif type == "phantom":
		hp -= damage
	
	if hp <= 0:
		hp = 0
		die()


func update_status():
	shield = 0


func gain_shield(value):
	shield += value
	


func die():
	print(char_name, " dead")
	emit_signal("died", self)
