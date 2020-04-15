extends Character
class_name Player

var hud

func _ready():
	init("player", 80)

func set_hud(_hud):
	hud = _hud

func damage(value):
	take_damage(value)
	hud.take_damage(value)

