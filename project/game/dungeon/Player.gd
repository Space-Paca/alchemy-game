extends Character
class_name Player

signal combination_discovered(combination, index)
signal resolved
signal draw_reagent
signal draw_resolve

const HAND_SIZES = [5,8,12]
const GRID_SIZES = [2,3,4]
const MAX_LEVEL = 3

export var initial_currency := 50

var currency : int
var gems : int
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
	gems = 0
	
	# Initial recipes
	known_recipes = player_class.initial_recipes.duplicate()
	known_recipes.sort()
	
	# Initial bag
	for _i in range(5):
		add_reagent("common", false)
	for _i in range(3):
		add_reagent("damaging", false)
	for _i in range(3):
		add_reagent("defensive", false)


func draw_reagents_resolve():
	emit_signal("draw_resolve")


func level_up():
	cur_level += 1
	if cur_level <= MAX_LEVEL:
		hand_size = HAND_SIZES[cur_level-1]
		grid_size = GRID_SIZES[cur_level-1]


func set_level(level:int):
	assert(level in [1, 2, 3], "Invalid level")
	cur_level = level
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]


func add_currency(amount: int):
	assert(amount > 0, "Amount must be positive")
	AudioManager.play_sfx("get_coins")
	currency += amount


func add_gems(amount: int):
	assert(amount > 0, "Amount must be positive")
	AudioManager.play_sfx("get_gem")
	gems += amount


func spend_currency(amount: int) -> bool:
	assert(amount > 0, "Amount must be positive")
	if currency >= amount:
		currency -= amount
		return true
	else:
		return false


func spend_gems(amount: int) -> bool:
	assert(amount > 0, "Amount must be positive")
	if gems >= amount:
		gems -= amount
		return true
	else:
		return false


func upgrade_reagent(index: int):
	bag[index].upgraded = true


func add_reagent(type, upgraded):
	bag.append({"type": type, "upgraded": upgraded})


func remove_reagent(type: String, upgraded: bool):
	for i in range(0, bag.size()):
		var reagent = bag[i]
		if reagent.type == type and reagent.upgraded == upgraded:
			bag.remove(i)
			break

#༼ つ ◕_◕ ༽つ༼
func destroy_reagent(index: int):
	bag.remove(index)


func set_hud(_hud):
	hud = _hud


func heal(amount : int):
	if amount > 0:
		var amount_healed = .heal(amount)
		
		#Animation
		AnimationManager.play("heal", hud.get_animation_position())
		
		if amount_healed > 0:
			hud.update_visuals(self)
		else:
			hud.dummy_rising_number()
		yield(hud, "animation_completed")
	
	emit_signal("resolved")

func draw(amount:int):
	emit_signal("draw_reagent", amount)
	
	yield(self, "draw_resolve")
	
	emit_signal("resolved")

func drain(source: Character, value):
	var unblocked_dmg = .take_damage(source, value, "drain")
	
	if unblocked_dmg > 0:
		source.heal(unblocked_dmg)

	#Animations
	AnimationManager.play("regular_attack", hud.get_animation_position())

	hud.update_status_bar(self)

	var func_state = hud.update_visuals(self)
	if func_state and func_state.is_valid():
		yield(hud, "animation_completed")

	emit_signal("resolved")

func take_damage(source: Character, value: int, type: String, retaliate := true):
	var _unblocked_dmg = .take_damage(source, value, type, retaliate)

	#Animations
	if type == "regular":
		AnimationManager.play("regular_attack", hud.get_animation_position())
	elif type == "piercing":
		AnimationManager.play("piercing_attack", hud.get_animation_position())
	elif type == "crushing":
		AnimationManager.play("crushing_attack", hud.get_animation_position())
	elif type == "poison":
		AnimationManager.play("poison", hud.get_animation_position())
	
	hud.update_status_bar(self)

	var func_state = hud.update_visuals(self)
	if func_state and func_state.is_valid():
		yield(hud, "animation_completed")

	emit_signal("resolved")

func reduce_status(status: String, amount: int):
	.reduce_status(status, amount)
	hud.update_status_bar(self)

func add_status(status: String, amount: int, positive: bool):
	.add_status(status, amount, positive)
	hud.update_status_bar(self)
	
	#Animations
	if positive:
		AnimationManager.play("buff", hud.get_animation_position())
	else:
		AnimationManager.play("debuff", hud.get_animation_position())

func gain_shield(amount: int):
	if amount > 0:
		.gain_shield(amount)
		
		#Animation
		AnimationManager.play("shield", hud.get_animation_position())
		
		hud.update_visuals(self)
		yield(hud, "animation_completed")
	
	emit_signal("resolved")


func new_turn():
	update_status()
	if hud.need_to_update_visuals(self):
		hud.update_visuals(self)
		yield(hud, "animation_completed")

func clear_status():
	.clear_status()
	hud.update_status_bar(self)

func update_status():
	.update_status()
	hud.update_status_bar(self)


func discover_combination(combination: Combination):
	if (known_recipes.has(combination.recipe.name)):
		return
	
	var recipe_name = combination.recipe.name
	var index = known_recipes.bsearch(recipe_name)
	known_recipes.insert(index, recipe_name)
	AudioManager.play_sfx("discover_new_recipe")
	emit_signal("combination_discovered", combination, index)
