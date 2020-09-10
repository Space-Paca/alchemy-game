extends Character
class_name Player

signal combination_discovered(combination, index)
signal resolved
signal draw_reagent
signal draw_resolve

const HAND_SIZES = [5,8,12]
const GRID_SIZES = [4,3,4]
const MAX_LEVEL = 3

export var initial_currency := 50

var currency : int
var gems : int
var hud
var hand_size : int
var grid_size : int
var bag := []
var artifacts := []
var known_recipes : Array
var cur_level : int
var player_class : PlayerClass


func _ready():
	# Only class we have right now
	player_class = load("res://database/player-classes/alchemist.tres") as PlayerClass
	cur_level = 1
	
	init("player", player_class.max_hps[cur_level-1])
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
		set_max_hp(player_class.max_hps[cur_level-1])
		full_heal()


func set_level(level:int):
	assert(level in [1, 2, 3], "Invalid level")
	cur_level = level
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]
	set_max_hp(player_class.max_hps[cur_level-1])
	full_heal()


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
	if has_artifact("buff_heal"):
# warning-ignore:narrowing_conversion
		amount = ceil(float(amount) * 1.5)
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

func drain(source: Character, value: int):
	#Check for weak status
	value = int(ceil(2*value/3.0)) if source.get_status("weak") else value
	
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
	#Check for weak status
	value = int(ceil(2*value/3.0)) if source.get_status("weak") else value
	
	var _unblocked_dmg = .take_damage(source, value, type, retaliate)

	#Animations
	if type == "regular":
		AnimationManager.play("regular_attack", hud.get_animation_position())
	elif type == "piercing":
		AnimationManager.play("piercing_attack", hud.get_animation_position())
	elif type == "crushing":
		AnimationManager.play("crushing_attack", hud.get_animation_position())
	elif type == "venom":
		AnimationManager.play("venom_attack", hud.get_animation_position())
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

func add_status(status: String, amount: int, positive: bool, extra_args:= {}):
	.add_status(status, amount, positive, extra_args)
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
	update_status("start_turn")
	if hud.need_to_update_visuals(self):
		hud.update_visuals(self)
		yield(hud, "animation_completed")

func clear_status():
	.clear_status()
	hud.update_status_bar(self)

func remove_status(status: String):
	.remove_status(status)
	hud.update_status_bar(self)

func update_status(type: String):
	.update_status(type)
	hud.update_status_bar(self)


func discover_combination(combination: Combination, play_sfx := false):
	if (known_recipes.has(combination.recipe.name)):
		return
	
	var recipe_name = combination.recipe.name
	var index = known_recipes.bsearch(recipe_name)
	known_recipes.insert(index, recipe_name)
	if play_sfx:
		AudioManager.play_sfx("discover_new_recipe")
	emit_signal("combination_discovered", combination, index)

func call_artifacts(func_name : String, args := {}):
	for artifact in artifacts:
		ArtifactManager.call("call_on_" + func_name, artifact, args)

func has_artifact(name : String):
	return artifacts.has(name)

func add_artifact(name : String):
	if not has_artifact(name):
		artifacts.append(name)
		ArtifactManager.call_on_add(name, {"player": self})
	else:
		assert(false, "Player already has artifact: " + str(name))

func remove_artifact(name : String):
	if has_artifact(name):
		artifacts.remove(artifacts.find(name))
	else:
		assert(false, "Player doesn't have artifact: " + str(name))
