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

func damage(value):
	take_damage(value)
	hud.take_damage(value)
