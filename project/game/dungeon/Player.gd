extends Character
class_name Player

const INITIAL_HAND_SIZE = 4
const INITIAL_GRID_SIZE = 2

var hud
var hand_size : int
var grid_size : int
var bag := []
var known_recipes : Array


func _ready():
	# Only class we have right now
	var player_class = load("res://database/player-classes/alchemist.tres") as PlayerClass
	
	init("player", player_class.initial_hp)
	hand_size = INITIAL_HAND_SIZE
	grid_size = INITIAL_GRID_SIZE
	
	# Initial recipes
	known_recipes = player_class.initial_recipes.duplicate()
	
	# Initial bag
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
	hud.update_shield(self)


func gain_shield(value):
	.gain_shield(value)
	hud.update_shield(self)


func update_status():
	.update_status()
	hud.update_status_bar(self)


func discover_combination(combination: Combination):
	print("Discovered new recipe: ", combination.recipe_name)
	known_recipes.append(combination.recipe_name)
