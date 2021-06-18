extends Character
class_name Player

signal combination_discovered(combination, index)
signal resolved
signal draw_reagent
signal draw_resolve
signal hp_updated(hp, max_hp)
signal gold_updated(gold)
signal pearls_updated(pearl)
signal bag_updated(bag)
signal artifacts_updated(artifacts)
signal reveal_map

const HAND_SIZES = [5,8,12]
const GRID_SIZES = [2,3,4]
const MAX_LEVEL = 3

export var initial_gold := 50

var gold : int
var pearls : int
var hud
var hand_size : int
var grid_size : int
var bag := []
var artifacts := []
var known_recipes : Array
var made_recipes : Dictionary
var cur_level : int
var floor_stats = [
	#Floor 1
	{
		"normal_encounters_finished": 0,
		"elite_encounters_finished": 0,
		"monsters_defeated": 0,
		"percentage_done": 0.0,
	},
	#Floor 2
	{
		"normal_encounters_finished": 0,
		"elite_encounters_finished": 0,
		"monsters_defeated": 0,
		"percentage_done": 0.0,
	},
	#Floor 3
	{
		"normal_encounters_finished": 0,
		"elite_encounters_finished": 0,
		"monsters_defeated": 0,
		"percentage_done": 0.0,
	},
]
var stats = {
	"reagents_removed": 0,
	"damage_dealt": 0,
	"damage_blocked": 0,
	"damage_received": 0,
	"damage_healed": 0,
	"shield_gain": 0,
	"recipes_made": 0,
	"recipes_discovered": 0
}

var player_class : PlayerClass


func _ready():
	# Only class we have right now
	player_class = load("res://database/player-classes/alchemist.tres") as PlayerClass
	cur_level = 1
	
	init("player", player_class.max_hps[cur_level-1])
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]
	gold = initial_gold
	pearls = 0
	
	# Initial recipes
	known_recipes = player_class.initial_recipes.duplicate()
	known_recipes.sort()
	reset_made_recipes()
	for recipe_name in known_recipes:
		saw_recipe(recipe_name)
	
	# Initial bag
	for _i in range(5):
		add_reagent("faint", false)
	for _i in range(3):
		add_reagent("weak_damaging", false)
	for _i in range(3):
		add_reagent("weak_defensive", false)
	
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("artifact_pressed", self, "_on_Debug_artifact_added")


func get_save_data():
	var data = {
		"bag": bag.duplicate(true),
		"gold": gold,
		"pearls": pearls,
		"cur_level": cur_level,
		"artifacts": artifacts.duplicate(true),
		"known_recipes": known_recipes.duplicate(true),
		"made_recipes": made_recipes.duplicate(true),
		"hp": hp,
		"max_hp": max_hp,
		"floor_stats": floor_stats.duplicate(true),
		"stats": stats.duplicate(true),
	}
	
	return data


func set_save_data(data):
	bag = data.bag
	gold = data.gold
	pearls = data.pearls
	cur_level = data.cur_level
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]
	artifacts = data.artifacts
	known_recipes = data.known_recipes
	made_recipes = data.made_recipes
	hp = data.hp
	max_hp = data.max_hp
	#Copy floor stats from data, but remain default values that are not present
	for level in data.floor_stats.size():
		for key in floor_stats[level].keys():
			if data.floor_stats[level].has(key):
				floor_stats[level][key] = data.floor_stats[level][key]
	#Copy stats from data, but remain default values that are not present
	for key in stats.keys():
		if data.stats.has(key):
			stats[key] = data.stats[key]


class BagSorter:
	static func sort_ascending_name(a, b):
		if a.type < b.type:
			return true
		elif a.type == b.type and a.upgraded:
			return true
		return false


func sort_bag():
	bag.sort_custom(BagSorter, "sort_ascending_name")

func draw_reagents_resolve():
	emit_signal("draw_resolve")


func level_up():
	cur_level += 1
	if cur_level <= MAX_LEVEL:
		hand_size = HAND_SIZES[cur_level-1]
		grid_size = GRID_SIZES[cur_level-1]
		if cur_level > 1:
			increase_max_hp(player_class.max_hps[cur_level-1] - player_class.max_hps[cur_level-2])
		else:
			set_max_hp(player_class.max_hps[cur_level-1])
		full_heal()


func set_level(level:int):
	assert(level in [1, 2, 3], "Invalid level")
	cur_level = level
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]
	set_max_hp(player_class.max_hps[cur_level-1])
	full_heal()


func set_floor_stat(type: String, value):
	floor_stats[cur_level-1][type] = value


func increase_floor_stat(type: String):
	floor_stats[cur_level-1][type] += 1


func increase_stat(type: String, how_much = 1):
	stats[type] += how_much


func full_heal():
	.full_heal()
	emit_signal("hp_updated", hp, max_hp)


func set_hp(new_value: int):
	hp = new_value
	emit_signal("hp_updated", hp, max_hp)


func set_max_hp(value):
	.set_max_hp(value)
	if hud and is_instance_valid(hud):
		hud.update_max_hp(value)
	emit_signal("hp_updated", hp, max_hp)


func add_gold(amount: int):
	assert(amount > 0, "Amount must be positive")
	AudioManager.play_sfx("get_coins")
	gold += amount
	emit_signal("gold_updated", gold)


func add_pearls(amount: int):
	assert(amount > 0, "Amount must be positive")
	AudioManager.play_sfx("get_pearl")
	pearls += amount
	emit_signal("pearls_updated", pearls)


func spend_gold(amount: int) -> bool:
	assert(amount > 0, "Amount must be positive")
	if gold >= amount:
		gold -= amount
		emit_signal("gold_updated", gold)
		return true
	else:
		return false


func spend_pearls(amount: int) -> bool:
	assert(amount > 0, "Amount must be positive")
	if pearls >= amount:
		pearls -= amount
		emit_signal("pearls_updated", pearls)
		return true
	else:
		return false


func upgrade_reagent(index: int):
	bag[index].upgraded = true
	sort_bag()
	emit_signal("bag_updated", bag)


func transmute_reagent(index: int, transmute_into: String):
	bag[index].type = transmute_into
	sort_bag()
	emit_signal("bag_updated", bag)


func add_reagent(type, upgraded):
	bag.append({"type": type, "upgraded": upgraded})
	sort_bag()
	emit_signal("bag_updated", bag)


func remove_reagent(type: String, upgraded: bool):
	for i in range(0, bag.size()):
		var reagent = bag[i]
		if reagent.type == type and reagent.upgraded == upgraded:
			bag.remove(i)
			break
	sort_bag()
	emit_signal("bag_updated", bag)


#༼ つ ◕_◕ ༽つ༼
func destroy_reagent(index: int):
	increase_stat("reagent_removed")
	bag.remove(index)
	sort_bag()
	emit_signal("bag_updated", bag)


func set_hud(_hud):
	hud = _hud


func heal(amount : int):
	if has_artifact("buff_heal"):
# warning-ignore:narrowing_conversion
		amount = ceil(float(amount) * 1.5)
	if amount > 0:
		var amount_healed = .heal(amount)
		
		increase_stat("damage_healed", amount_healed)
		
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
	#Check for weakness status
	value = int(ceil(2*value/3.0)) if source.get_status("weakness") else value
	
	var unblocked_dmg = .take_damage(source, value, "drain")
	
	increase_stat("damage_blocked", value - unblocked_dmg)
	increase_stat("damage_received", unblocked_dmg)
	
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
	#Check for weakness status
	value = int(ceil(2*value/3.0)) if source.get_status("weakness") else value
	
	var unblocked_dmg = .take_damage(source, value, type, retaliate)
	
	increase_stat("damage_blocked", value - unblocked_dmg)
	increase_stat("damage_received", unblocked_dmg)

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


#Add status without any effects, when loading hard data
func hard_set_status(status, amount, positive, extra_args):
	.add_status(status, amount, positive, extra_args)
	hud.update_status_bar(self)


func add_status(status: String, amount: int, positive: bool, extra_args:= {}):
	.add_status(status, amount, positive, extra_args)
	hud.update_status_bar(self)
	
	#Animations
	if positive:
		AnimationManager.play("buff", hud.get_animation_position())
	else:
		AnimationManager.play("debuff", hud.get_animation_position())


func hard_set_shield(amount: int):
	shield = amount
	hud.update_visuals(self)


func gain_shield(amount: int):
	if amount > 0:
		.gain_shield(amount)
		
		increase_stat("shield_gain", amount)
		
		#Animation
		AnimationManager.play("shield", hud.get_animation_position())
		
		hud.update_visuals(self)
		yield(hud, "animation_completed")
	
	emit_signal("resolved")


func new_turn():
	update_status("start_turn")
	call_artifacts("turn_start", {"player": self})
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


func reset_made_recipes():
	made_recipes.clear()
	for recipe in RecipeManager.recipes.values():
		made_recipes[recipe.name] = {
			"amount": -1,
		}

func saw_recipe(name):
	assert(made_recipes.has(name), "Not a valid recipe name: "+str(name))
	if made_recipes[name].amount == -1:
		made_recipes[name].amount = 0

func made_recipe(name):
	assert(made_recipes.has(name), "Not a valid recipe name: "+str(name))
	if made_recipes[name].amount == -1:
		made_recipes[name].amount = 1
	else:
		made_recipes[name].amount += 1
	increase_stat("recipes_made")


func discover_combination(combination: Combination, play_sfx := false):
	if (known_recipes.has(combination.recipe.name)):
		return
	
	var recipe_name = combination.recipe.name
	var index = known_recipes.bsearch(recipe_name)
	known_recipes.insert(index, recipe_name)
	if play_sfx:
		AudioManager.play_sfx("discover_new_recipe")
	emit_signal("combination_discovered", combination, index)


func get_artifacts():
	return artifacts


func call_artifacts(func_name : String, args := {}):
	for artifact in artifacts:
		ArtifactCallbacks.call("call_on_" + func_name, artifact, args)


func has_artifact(name : String):
	return artifacts.has(name)


func add_artifact(name : String):
	if not has_artifact(name):
		AudioManager.play_sfx("get_artifact")
		artifacts.append(name)
		ArtifactCallbacks.call_on_add(name, {"player": self})
		emit_signal("artifacts_updated", artifacts)
	else:
		assert(false, "Player already has artifact: " + str(name))


func remove_artifact(name : String):
	if has_artifact(name):
		artifacts.remove(artifacts.find(name))
		emit_signal("artifacts_updated", artifacts)
	else:
		assert(false, "Player doesn't have artifact: " + str(name))


func reveal_map():
	emit_signal("reveal_map")


func get_discovered_recipes_amount():
	pass


func get_made_recipes_amount() -> int:
	var total : int
	for r in made_recipes:
		if made_recipes[r].amount > 0:
			total += made_recipes[r].amount
	
	return total


func _on_Debug_artifact_added(name: String):
	if not has_artifact(name):
		add_artifact(name)
