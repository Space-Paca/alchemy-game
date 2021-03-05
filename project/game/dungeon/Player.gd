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
var cur_level : int
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
	
	# Initial bag
	for _i in range(5):
		add_reagent("faint", false)
	for _i in range(3):
		add_reagent("weak_damaging", false)
	for _i in range(3):
		add_reagent("weak_defensive", false)


func get_save_data():
	var data = {
		"bag": bag.duplicate(true),
		"gold": gold,
		"pearls": pearls,
		"cur_level": cur_level,
		"artifacts": artifacts.duplicate(true),
		"known_recipes": known_recipes.duplicate(true),
		"hp": hp,
		"max_hp": max_hp,
	}
	
	return data


func set_save_data(data):
	bag = data.bag
	gold = data.gold
	pearls = data.pearls
	cur_level = data.cur_level
	artifacts = data.artifacts
	known_recipes = data.known_recipes
	hp = data.hp
	max_hp = data.max_hp


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
		set_max_hp(player_class.max_hps[cur_level-1])
		full_heal()


func set_level(level:int):
	assert(level in [1, 2, 3], "Invalid level")
	cur_level = level
	hand_size = HAND_SIZES[cur_level-1]
	grid_size = GRID_SIZES[cur_level-1]
	set_max_hp(player_class.max_hps[cur_level-1])
	full_heal()


func full_heal():
	.full_heal()
	emit_signal("hp_updated", hp, max_hp)


func set_hp(new_value: int):
	hp = new_value
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


func get_artifacts():
	return artifacts


func call_artifacts(func_name : String, args := {}):
	for artifact in artifacts:
		ArtifactCallbacks.call("call_on_" + func_name, artifact, args)


func has_artifact(name : String):
	return artifacts.has(name)


func add_artifact(name : String):
	if not has_artifact(name):
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
