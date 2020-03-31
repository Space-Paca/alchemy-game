extends Reference
class_name Character

var max_hp : int
var hp : int
var shield : int
var name : String

func _init(_name: String, _max_hp: int):
	name = _name
	max_hp = _max_hp


func take_damage(damage):
	hp -= damage
	if hp <= 0:
		hp = 0
		die()


func die():
	print(name, " dead")
