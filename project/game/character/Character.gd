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


func take_damage(damage):
	#Block damage with shield
	damage = max(damage - shield, 0)
	shield = max(shield - damage, 0)
	
	hp -= damage
	if hp <= 0:
		hp = 0
		die()

func shield(value):
	shield += value
	

func die():
	print(char_name, " dead")
	emit_signal("died", self)
