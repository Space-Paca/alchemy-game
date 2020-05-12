extends Character
class_name Player

signal combination_discovered(combination, index)

const HAND_SIZES = [4,8,12]
const GRID_SIZES = [2,3,4]
const MAX_LEVEL = 3

export var initial_currency := 100

var currency : int
var hud
var hand_size : int
var grid_size : int
var bag := []
var known_recipes : Array
var cur_level : int


func _ready():
	# Only class we have right now
	var player_class = load("res://database/player-classes/alchemist.tres") as PlayerClass
	cur_level = 1
	
	init("player", player_class.initial_hp)
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]
	currency = initial_currency
	
	# Initial recipes
	known_recipes = player_class.initial_recipes.duplicate()
	known_recipes.sort()
	
	# Initial bag
	for _i in range(3):
		add_reagent("common")
	for _i in range(2):
		add_reagent("damaging")
	for _i in range(2):
		add_reagent("defensive")


func level_up():
	cur_level += 1
	if cur_level <= MAX_LEVEL:
		hand_size = HAND_SIZES[cur_level-1]
		grid_size = GRID_SIZES[cur_level-1]


func add_currency(amount: int):
	assert(amount > 0)
	currency += amount


func spend_currency(amount: int) -> bool:
	assert(amount > 0)
	if currency >= amount:
		currency -= amount
		return true
	else:
		return false


func add_reagent(type):
	bag.append(type)


func set_hud(_hud):
	hud = _hud


func heal(amount : int):
	.heal(amount)
	hud.update_life(self)


func take_damage(source: Character, value: int, type: String):
	.take_damage(source, value, type)
	hud.update_life(self)
	hud.update_shield(self)
	hud.update_status_bar(self)


func add_status(status: String, amount: int, positive: bool):
	.add_status(status, amount, positive)
	hud.update_status_bar(self)


func gain_shield(value):
	.gain_shield(value)
	hud.update_shield(self)


func new_turn():
	update_status()
	hud.update_shield(self)


func update_status():
	.update_status()
	hud.update_status_bar(self)


func discover_combination(combination: Combination):
	var recipe_name = combination.recipe.name
	var index = known_recipes.bsearch(recipe_name)
	known_recipes.insert(index, recipe_name)
	AudioManager.play_sfx("discover_new_recipe")
	emit_signal("combination_discovered", combination, index)
