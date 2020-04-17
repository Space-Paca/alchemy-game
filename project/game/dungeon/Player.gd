extends Character
class_name Player

var hud
var hand_size
var grid_size
var bag = []

func _ready():
	init("player", 80)
	hand_size = 4
	grid_size = 2
	#Initial bag
	for _i in range(3):
		add_reagent("common")
	for _i in range(2):
		add_reagent("damaging")
	for _i in range(2):
		add_reagent("defensive")

func add_reagent(type):
	bag.append(type)

func set_hud(_hud):
	hud = _hud

func heal(amount : int):
	.heal(amount)
	hud.update_life(self)

func take_damage(value):
	.take_damage(value)
	hud.update_life(self)
	hud.update_status_bar(self)

func gain_shield(value):
	.gain_shield(value)
	hud.update_status_bar(self)

func update_status():
	.update_status()
	hud.update_status_bar(self)
