extends Node
class_name Character

var max_hp : int
var hp : int
var shield : int
var char_name: String 

func init(_name: String, _max_hp: int):
	char_name = _name
	max_hp = _max_hp
	hp = max_hp


func take_damage(damage):
	hp -= damage
	if hp <= 0:
		hp = 0
		die()


func die():
	print(char_name, " dead")
