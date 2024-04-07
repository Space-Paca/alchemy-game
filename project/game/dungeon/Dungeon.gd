extends Node

onready var player = $Player
onready var recipe_book : RecipeBook = $BookLayer/RecipeBook
onready var player_info = $BookLayer/PlayerInfo
onready var shop = $Shop
onready var rest = $Rest
onready var lab = $Laboratory
onready var smith = $Blacksmith
onready var treasure = $Treasure
onready var event_display = $EventDisplay
onready var timer = $UI/Timer
onready var page_flip = $BookLayer/PageFlip

const BATTLE_SCENE = preload("res://game/battle/Battle.tscn")
const MAP_SCENE = preload("res://game/map/Map.tscn")
const EVENT_SCENE = preload("res://game/event/EventDisplay.tscn")
const RECIPES_REWARDED_PER_BATTLE = 3
const SAVE_VERSION = 2.0

var battle
var combinations := {}
var failed_combinations := []
var time_of_run = 0.0
var time_running = false
var difficulty = "normal"
var floor_level := 1
var times_recipe_made := {}
var max_favorites := 8
var possible_rewarded_combinations := []
var map : Map
var current_node : MapNode
var laboratory_attempts = [6,7,8]
var cur_lab_attempts
var battle_load_data = false
var first_shop_visit = true
var times_removed_reagent = 0


func _ready():
	randomize()
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("combinations_unlocked", self, "_on_Debug_combinations_unlocked")
# warning-ignore:return_value_discarded
	Debug.connect("floor_selected", self, "_on_Debug_floor_selected")
# warning-ignore:return_value_discarded
	Debug.connect("test_map_creation", self, "_on_Debug_test_map_creation")
# warning-ignore:return_value_discarded
	Debug.connect("event_pressed", self, "_on_Debug_event_pressed")


# warning-ignore:return_value_discarded
	rest.connect("combination_studied", self, "_on_combination_studied")
# warning-ignore:return_value_discarded
	lab.connect("combination_made", self, "_on_Laboratory_combination_made")
# warning-ignore:return_value_discarded
	lab.connect("grid_modified", self, "_on_Laboratory_grid_modified")
# warning-ignore:return_value_discarded
	MessageLayer.connect("favorite_recipe", self, "_on_favorite_recipe")

# warning-ignore:return_value_discarded
	player.connect("reveal_map", self, "_on_player_reveal_map")
	
	timer.update_timer(time_of_run)
	time_running = false
	timer.visible = Profile.get_option("show_timer")
	
	FileManager.set_current_run(self)
	
	if FileManager.continue_game:
		FileManager.continue_game = false
		FileManager.load_run()
	else:
		if Debug.floor_to_go != -1:
			floor_level = Debug.floor_to_go
			player.set_level(floor_level)
		difficulty = FileManager.difficulty_to_use
		player.difficulty = difficulty
		create_combinations()
		EventManager.reset_events()
		create_level(floor_level)
	if floor_level >= 1 and floor_level <= 3:
		Steam.set_rich_presence(tr("FLOOR_NAME_" + str(floor_level)), "floor")
	else:
		Steam.set_rich_presence(tr("FLOOR_NAME_1"), "floor")
		
	
	play_map_bgm()
	
	recipe_book.set_player(player)
	player.connect("bag_updated", $BookLayer/RecipeBook, "update_reagents")
	player_info.set_player(player)
	
	$PauseScreen.set_block_pause(true)
	
	yield(map, "finished_active_paths")
	if battle_load_data:
		map.set_disabled(true)
		yield(get_tree().create_timer(.5), "timeout")
		$PauseScreen.set_block_pause(false)
		load_battle(battle_load_data)
		battle_load_data = false
	else:
		if not Profile.get_tutorial("map"):
			TutorialLayer.start("map")
			yield(TutorialLayer, "tutorial_finished")
			Profile.set_tutorial("map", true)
		$PauseScreen.set_block_pause(false)
		time_running = true


func _input(event):
	if event.is_action_pressed("show_recipe_book"):
		if not (battle and battle.player_disabled) and not TutorialLayer.is_active() \
		   and Profile.get_tutorial("clicked_recipe"):
			recipe_book_toggle()
			TooltipLayer.clean_tooltips()
	elif event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		Profile.set_option("fullscreen", OS.window_fullscreen, true)
		if not OS.window_fullscreen:
			yield(get_tree(), "idle_frame")
			OS.window_size = Profile.WINDOW_SIZES[Profile.get_option("window_size")]
			OS.window_position = Vector2(0,0)


func _process(delta):
	if time_running:
		time_of_run += delta
		timer.update_timer(time_of_run) 


func get_save_data():
	var data = {
		"save_version": SAVE_VERSION,
		"player": player.get_save_data(),
		"combinations": get_combinations_data(),
		"favorites": get_favorite_data(),
		"encounters": EncounterManager.get_save_data(),
		"events": EventManager.get_save_data(),
		"map": map.get_save_data(),
		"cur_lab_attempts": cur_lab_attempts,
		"first_shop_visit": first_shop_visit,
		"shop_data": [] if first_shop_visit else shop.get_save_data(),
		"battle": battle.get_save_data() if battle else false,
		"current_node": "" if (not current_node or not is_instance_valid(current_node)) else current_node.name,
		"time_of_run": time_of_run,
		"times_removed_reagent": times_removed_reagent,
		"difficulty": difficulty,
	}
	return data


func set_save_data(data):
	if data.save_version != SAVE_VERSION:
		print("Different save version on loaded run.")
		print("Game version: " + str(SAVE_VERSION) + "; Saved run version: " + str(data.save_version))
		if not data.has("difficulty"):
			data.difficulty = "normal"
	
	player.set_save_data(data.player)
	player_info.update_artifacts(player)
	floor_level = player.cur_level
	load_combinations(data.combinations)
	set_favorite_data(data.favorites)
	EventManager.load_save_data(data.events)
	load_level(data)
	battle_load_data = data.battle
	current_node = null if data.current_node == "" else map.get_map_node(data.current_node)
	time_of_run = data.time_of_run
	times_removed_reagent = data.times_removed_reagent if data.has("times_removed_reagent") else 0
	timer.update_timer(time_of_run)
	difficulty = data.difficulty if data.has("difficulty") else "normal"


func play_map_bgm():
	AudioManager.play_bgm("map" + str(floor_level))
	AudioManager.play_ambience(floor_level)


func get_combinations_data():
	var data = []
	
	for size_array in combinations.values():
		for combination in size_array:
			var times_made = 0
			if times_recipe_made.has(combination.recipe.id):
				times_made = times_recipe_made[combination.recipe.id]
			var comb = {
				"recipe_id": combination.recipe.id,
				"matrix": combination.matrix.duplicate(true),
				"known_matrix": combination.known_matrix.duplicate(true),
				"unknown_reagent_coords": combination.unknown_reagent_coords.duplicate(true),
				"discovered": combination.discovered,
				"reagent_amounts": combination.reagent_amounts.duplicate(true),
				"hints": combination.hints,
				"times_made": times_made,
			}
			data.append(comb)
		
	return data


func get_combination_by_name(recipe_name):
	for size_array in combinations.values():
		for combination in size_array:
			if combination.recipe.name == recipe_name:
				return combination
	push_error("Not a valid combination name: " + str(recipe_name))
	return null

func load_combinations(combinations_data):
	for data_combination in combinations_data:
		var combination = Combination.new()
		
		data_combination.combination = combination
		
		#Find correspondent recipe object belonging to this combination
		var recipe_ref = null
		for recipe_id in RecipeManager.recipes.keys():
			if recipe_id == data_combination.recipe_id:
				recipe_ref = RecipeManager.recipes[recipe_id]
				break
		assert(recipe_ref, "Coudn't find this recipe to load combination:" + str(data_combination.recipe_id))
		
		combination.load_from_data(data_combination, recipe_ref)
		combination.connect("fully_discovered", self, "_on_Combination_fully_discovered")
		
		if combinations.has(combination.grid_size):
			(combinations[combination.grid_size] as Array).append(combination)
		else:
			combinations[combination.grid_size] = [combination]
		
		if data_combination.times_made > 0:
			times_recipe_made[combination.recipe.id] = data_combination.times_made
		
	#Update recipe book in the order recipes were discovered
	for recipe_id in player.known_recipes:
		var data_combination = null
		for data in combinations_data:
			if data.recipe_id == recipe_id:
				data_combination = data
				break
		assert(data_combination, "Couldn't find combination for this recipe: " + str(recipe_id))
		var combination = data_combination.combination
		recipe_book.add_combination(combination, mastery_threshold(combination))
		if should_unlock_mastery(combination):
			recipe_book.unlock_mastery(combination, false)
		else:
			recipe_book.update_mastery(combination, data_combination.times_made,\
								   mastery_threshold(combination))


func create_combinations():
	var unlocked_recipes = UnlockManager.get_all_unlocked_recipes()
	for recipe_id in RecipeManager.recipes.keys():
		var recipe = RecipeManager.recipes[recipe_id]
		if (recipe.must_unlock and unlocked_recipes.find(recipe_id) == -1) or\
		 	(Debug.is_demo and not recipe.use_on_demo):
			continue
		
		var combination = Combination.new()
		combination.create_from_recipe(recipe, combinations)
		combination.connect("fully_discovered", self, "_on_Combination_fully_discovered")
		
		if combinations.has(combination.grid_size):
			(combinations[combination.grid_size] as Array).append(combination)
		else:
			combinations[combination.grid_size] = [combination]
		
		if player.known_recipes.has(recipe.id):
			combination.discover_all_reagents("new_game")
			recipe_book.add_combination(combination, mastery_threshold(combination))
			if Profile.get_recipe_memorized_level(combination.recipe.id) >= 1:
				favorite_combination(combination, true, false)
				recipe_book.set_favorite_button(combination, true, true)
		if Profile.get_recipe_memorized_level(combination.recipe.id) >= 2:
			player.discover_combination(combination)
			player.saw_recipe(combination.recipe.id)
		if Profile.get_recipe_memorized_level(combination.recipe.id) >= 4:
			combination.reveal_all_but(3)
			recipe_book.update_combination(combination)
		


func get_favorite_data():
	var favorites = []
	for combination in recipe_book.favorite_combinations:
		favorites.append(combination.recipe.name)
	return favorites


func set_favorite_data(data):
	for recipe_name in data:
		var combination = get_combination_by_name(recipe_name)
		favorite_combination(combination, true, false)
		recipe_book.set_favorite_button(combination, true, true)


func load_level(data):
	EncounterManager.load_save_data(data.encounters)

	var level = floor_level
	
	# MAP
	map = MAP_SCENE.instance()
	# warning-ignore:return_value_discarded
	map.connect("finished_active_paths", self, "_on_map_finished_revealing_map")
	map.set_player(player)
	add_child(map)
	map.set_level(level)
	map.load_map(data.map)
	map.connect("map_node_pressed", self, "_on_map_node_selected")
	
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if combination.recipe.floor_sold_in == level and not\
					combination.discovered:
				possible_rewarded_combinations.append(combination)
	
	# SHOP
	first_shop_visit = data.first_shop_visit
	#If already went to shop before, must load saved combinations
	if not first_shop_visit:
		var shop_combinations = []
		for recipe_name in data.shop_data:
			shop_combinations.append(get_combination_by_name(recipe_name))
		shop.load_combinations(shop_combinations, player, self)
	
	#LAB
	cur_lab_attempts = data.cur_lab_attempts
	
	updateMapFog()

func create_level(level: int, debug := false):
	EncounterManager.set_random_encounter_pool(level)
	
	# MAP
	map = MAP_SCENE.instance()
	# warning-ignore:return_value_discarded
	map.connect("finished_active_paths", self, "_on_map_finished_revealing_map")
	map.set_player(player)
	add_child(map)
	var smith_amount = 1 if UnlockManager.is_misc_unlocked("REAGENT_SMITH") else 0
	var lab_amount = 1 if UnlockManager.is_misc_unlocked("LABORATORY") else 0
	map.set_level(level)
	# ( *∀*)y─┛
	#  ______________
	# (̅_̅_̅_̅(̅_̅_̅_̅_̅_̅_̅_̅_̅̅_̅()ڪے~
	match level:
		1:
			if Debug.is_demo:
				map.create_map(level, 3, 1, 0, 1, 1, 1, lab_amount, 1)
			else:
				map.create_map(level, 7, 2, 0, 2, 1, 1, lab_amount, 1)
		2:
			if Debug.is_demo:
				map.create_map(level, 3, 1, smith_amount, 1, 1, 1, lab_amount, 1)
			else:
				map.create_map(level, 7, 2, smith_amount, 2, 1, 1, lab_amount, 1)
		3:
			map.create_map(level, 8, 2, smith_amount, 2, 1, 1, lab_amount, 1)
		var invalid:
			assert(false, str("Invalid level: ", invalid))
	map.connect("map_node_pressed", self, "_on_map_node_selected")
	
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if combination.recipe.floor_sold_in == level and not\
					combination.discovered:
				possible_rewarded_combinations.append(combination)
	
	# SHOP
	first_shop_visit = true
	
	#LAB
	cur_lab_attempts = laboratory_attempts[level - 1]
	
	updateMapFog()
	
	if debug:
		map.queue_free()


func get_rest_combinations():
	var rest_combinations = []
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if player.known_recipes.has(combination.recipe.id) and (not combination.discovered or not recipe_book.is_mastered(combination)):
				rest_combinations.append(combination)
	
	return rest_combinations


func setup_shop():
	var shop_combinations = []
	var unknown = []
	var incomplete = []
	var complete = []
	
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if combination.recipe.floor_sold_in != floor_level:
				continue
			
			if not player.known_recipes.has(combination.recipe.id):
				unknown.append(combination)
			elif not combination.discovered:
				incomplete.append(combination)
			else:
				complete.append(combination)
	
	for array in [unknown, incomplete, complete]:
		array.shuffle()
	
	for i in shop.sold_amount:
		for array in [unknown, incomplete, complete]:
			if array.size():
				shop_combinations.append(array.pop_front())
				break
		if shop_combinations.size() == i:
			shop_combinations.append(null)
	
	shop.first_setup(shop_combinations, player, self)


func updateMapFog():
	if Profile.get_option("disable_map_fog"):
		map.disable_map_fog()
	else:
		map.enable_map_fog()


func is_single_reagent(reagent_matrix):
	var count = 0
	for i in reagent_matrix.size():
		for j in reagent_matrix[i].size():
			if reagent_matrix[i][j]:
				count += 1
				if count > 1:
					return false
	return true


func get_combination_in_grid(reagent_matrix: Array, grid_size : int) -> Combination:
	var possible_combinations = get_possible_combinations(reagent_matrix, grid_size)
	var grid_combination = get_combination_in_matrix(grid_size, reagent_matrix, possible_combinations)
	
	if grid_combination:
		return grid_combination
	
	#Get total number of reagents in grid
	var total_reagents = 0
	for i in range(grid_size):
		for j in range(grid_size):
			if reagent_matrix[i][j]:
				total_reagents += 1

	var new_grid_size = grid_size
	while new_grid_size > 2:
		new_grid_size -= 1
		possible_combinations = get_possible_combinations(reagent_matrix, new_grid_size)
		var new_matrix = []
		for _i in range(new_grid_size):
			var line = []
			for _j in range(new_grid_size):
				line.append(null)
			new_matrix.append(line)
		
		for i_offset in range(grid_size - new_grid_size + 1):
			for j_offset in range(grid_size - new_grid_size + 1):
				
				var new_matrix_reagents = 0
				for i in range(new_grid_size):
					for j in range(new_grid_size):
						new_matrix[i][j] = reagent_matrix[i+i_offset][j+j_offset]
						if new_matrix[i][j]:
							new_matrix_reagents += 1
				
				#Makes sure there are no reagents outside this submatrix
				if new_matrix_reagents == total_reagents:
					grid_combination = get_combination_in_matrix(new_grid_size, new_matrix, possible_combinations)
					if grid_combination:
						return grid_combination
	
	return null

#Given a reagent matrix and grid size, return an array containing all possible combinations it could solve
#based on the pre-constructed reagent combinations for each recipe
func get_possible_combinations(reagent_matrix : Array, grid_size : int):
	var possible_combinations = []
	var reagent_array = []
	for i in reagent_matrix.size():
		for j in reagent_matrix[i].size():
			if reagent_matrix[i][j]:
				reagent_array.append(reagent_matrix[i][j])
	#Since the pre-constructed reagent combinations arrays are sorted, we must
	#sort our array for easy comparison
	reagent_array.sort()
	for combination in combinations[grid_size]:
		if combination.recipe.reagent_combinations.has(reagent_array):
			possible_combinations.append(combination)
	
	return possible_combinations


func get_combination_in_matrix(grid_size: int, reagent_matrix: Array, possible_combinations : Array) -> Combination:
	if not combinations.has(grid_size):
		print("No recipes exist for grid with size ", grid_size)
		return null
	for combination in possible_combinations:
		var equal = true
		for i in grid_size:
			for j in grid_size:
				if reagent_matrix[i][j] != combination.matrix[i][j] and \
				   not (reagent_matrix[i][j] and combination.matrix[i][j] and \
				   ReagentManager.substitute_into(combination.matrix[i][j]).has(reagent_matrix[i][j])):
					equal = false
					break
			if not equal:
				break
		if equal:
			return combination
	
	return null

func make_combination(type: String, combination: Combination, boost_effects: Dictionary, apply_effects := true):
	var recipe := combination.recipe
	
	if not player.known_recipes.has(recipe.id) or not combination.discovered:
		combination.discover_all_reagents(type)
		player.discover_combination(combination)
		AudioManager.play_sfx("discover_new_recipe")
		MessageLayer.new_recipe_discovered(combination)
		recipe_book.update_combination(combination)
		if battle:
			battle.disable_elements()
		yield(MessageLayer, "continued")
		if battle:
			battle.enable_elements()
	
	if apply_effects:
		player.made_recipe(recipe.id)
		battle.add_recipe_deviation(recipe.id)
		battle.grid.set_combination_icon(recipe.fav_icon)
		battle.grid.set_combination_sfx(recipe.sfx)
		if not times_recipe_made.has(recipe.id):
			times_recipe_made[recipe.id] = 1
		else:
			times_recipe_made[recipe.id] += 1
		
		if not recipe_book.is_mastered(combination) and should_unlock_mastery(combination):
			recipe_book.unlock_mastery(combination)
			if battle:
				battle.disable_elements()
			yield(MessageLayer, "continued")
			if battle:
				battle.enable_elements()
		else:
			recipe_book.update_mastery(combination, times_recipe_made[recipe.id],
					mastery_threshold(combination))
		
		if recipe_book.is_mastered(combination):
			battle.apply_effects(recipe.master_effects, recipe.master_effect_args, \
								 recipe.master_destroy_reagents, recipe.master_exile_reagents, boost_effects)
		else:
			battle.apply_effects(recipe.effects, recipe.effect_args, recipe.destroy_reagents,\
								 recipe.exile_reagents, boost_effects)
		
	elif not times_recipe_made.has(recipe.id):
		times_recipe_made[recipe.id] = 0


func mastery_threshold(combination: Combination, force_reduction := false) -> int:
	if Debug.lower_threshold:
		return 1
	var threshold = min(10, 18 - combination.recipe.reagents.size() - 6*combination.recipe.destroy_reagents.size()\
					-2*combination.recipe.exile_reagents.size() - 2*combination.recipe.grid_size)
	if combination.recipe.mastery_offset:
		threshold += combination.recipe.mastery_offset
	if force_reduction or Profile.get_recipe_memorized_level(combination.recipe.id) >= 3:
		threshold = min(floor(threshold*.8), threshold - 1)
	threshold = max(threshold, 2)
	return threshold


func should_unlock_mastery(combination: Combination) -> bool:
	if not times_recipe_made.has(combination.recipe.id):
		return false
	
	return times_recipe_made[combination.recipe.id] >= mastery_threshold(combination)


func create_battle():
	battle = BATTLE_SCENE.instance()
	
# warning-ignore:return_value_discarded
	battle.connect("combination_made", self, "_on_Battle_combination_made")
# warning-ignore:return_value_discarded
	battle.connect("won", self, "_on_Battle_won")
# warning-ignore:return_value_discarded
	battle.connect("finished", self, "_on_Battle_finished")
# warning-ignore:return_value_discarded
	battle.connect("rewarded_combinations_seen", self, "_on_new_combinations_seen")
# warning-ignore:return_value_discarded
	battle.connect("combination_rewarded", self, "_on_combination_rewarded")
# warning-ignore:return_value_discarded
	battle.connect("grid_modified", self, "_on_Battle_grid_modified")
# warning-ignore:return_value_discarded
	battle.connect("recipe_book_toggle", self, "recipe_book_toggle")
# warning-ignore:return_value_discarded
	battle.connect("update_recipes_display", self, "_on_Battle_update_recipes_display")
# warning-ignore:return_value_discarded
	battle.connect("block_pause", self, "_on_Battle_block_pause")
# warning-ignore:return_value_discarded
	battle.connect("player_died", self, "_on_Battle_player_died")
	
	player_info.hide()
	
	add_child(battle)



func load_battle(data):
	assert(battle == null)
	TooltipLayer.clean_tooltips()
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	map.disable()
	
	create_battle()
	
	battle.load_state(data, player, recipe_book.favorite_combinations, floor_level, recipe_book, difficulty)
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	
	recipe_book.change_state(RecipeBook.States.BATTLE)
	recipe_book.create_hand(battle)
	map.set_disabled(false)
	
	var encounter = EncounterManager.load_resource(data.encounter)
	if encounter.is_boss:
		Steam.set_rich_presence(tr("BOSS"), "enemy_type")
	elif encounter.is_elite:
		Steam.set_rich_presence(tr("ELITE"), "enemy_type")
	else:
		Steam.set_rich_presence(tr("ENEMY"), "enemy_type")
	Steam.set_rich_presence("#InBattle")


func new_battle(encounter: Encounter, is_event := false):
	assert(battle == null)
	create_battle()
	
	#DEBUG spawna último boss
	#encounter = EncounterManager.boss_encounters[3].front()
	
	battle.setup(player, encounter, recipe_book.favorite_combinations, floor_level, recipe_book, is_event, difficulty)
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	
	recipe_book.change_state(RecipeBook.States.BATTLE)
	recipe_book.create_hand(battle)
	
	if encounter.is_boss:
		Steam.set_rich_presence(tr("BOSS"), "enemy_type")
	elif encounter.is_elite:
		Steam.set_rich_presence(tr("ELITE"), "enemy_type")
	else:
		Steam.set_rich_presence(tr("ENEMY"), "enemy_type")
	Steam.set_rich_presence("#InBattle")

func open_shop():
	AudioManager.play_bgm("shop")
	
	if first_shop_visit:
		first_shop_visit = false
		setup_shop()
	
	shop.setup()
	shop.show()
	
	Transition.end_transition()
	yield(Transition, "finished")
	shop.start()
	time_running = true
	Steam.set_rich_presence("#InShop")


func open_rest(room, _player):
	AudioManager.play_bgm("rest")
	rest.setup(room, _player, get_rest_combinations())
	rest.show()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	Steam.set_rich_presence("#InRest")


func open_smith(room, _player):
	AudioManager.play_bgm("blacksmith")
	smith.setup(room, _player)
	smith.show()
	
	Transition.end_transition()
	yield(Transition, "finished")
	smith.start()
	time_running = true
	Steam.set_rich_presence("#InSmith")


func open_lab(room, _player):
	AudioManager.play_bgm("laboratory")
	recipe_book.change_state(RecipeBook.States.LAB)
	lab.setup(room, _player, cur_lab_attempts)
	lab.show()
	player_info.hide()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	Steam.set_rich_presence("#InLab")


func open_treasure(room, _player):
	AudioManager.play_bgm("treasure")
	treasure.setup(room, _player, floor_level)
	treasure.show()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	Steam.set_rich_presence("#InTreasure")


func open_event(map_node: MapNode):
	var event = EventManager.get_random_event(floor_level)
	event_display.set_map_node(map_node)
	if event.bgm != null:
		AudioManager.play_bgm(event.bgm)
	event_display.load_event(event, player)
	show_event()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	Steam.set_rich_presence("#InEvent")


func extract_boost_effects(reagents):
	var effects = {
		"all": 0,
		"damage": 0,
		"shield": 0,
		"status": 0,
		"heal": 0,
	}
	for reagent in reagents:
		if reagent.is_upgraded():
			var data = ReagentDB.get_from_name(reagent.type).effect
			var boost
			if typeof(data) == TYPE_ARRAY:
				for effect in data:
					boost = effect.upgraded_boost
					effects[boost.type] += boost.value
			else:
				boost = data.upgraded_boost
				effects[boost.type] += boost.value
	return effects


func enable_map():
	map.enable()
	player_info.update_values(player)
	player_info.show()
	Steam.set_rich_presence("#InMap")


func recipe_book_toggle():
	if (battle and is_instance_valid(battle)) or\
		(lab and is_instance_valid(lab) and lab.visible):
		if page_flip.flipping:
			return
		if recipe_book.is_open:
			page_flip.flip_right()
			yield(page_flip, "animation_ended")
		else:
			page_flip.flip_left()
			yield(page_flip, "fade_ended")
	
	var book_visible = recipe_book.toggle_visibility()
	if book_visible:
		recipe_book.update_player_info()
	if map and is_instance_valid(map):
		map.recipe_toogle(book_visible)
	if battle and is_instance_valid(battle):
		battle.recipe_book_toggled(book_visible)
	elif not lab.visible:
		player_info.visible = !book_visible
	
	if lab.visible:
		lab.recipe_book_visibility(book_visible)


func show_event():
	event_display.show()
	$PauseScreen.set_block_pause(true)


func hide_event():
	event_display.hide()
	$PauseScreen.set_block_pause(false)


func favorite_combination(combination, active, play_sfx = true):
	if active:
		if recipe_book.favorite_combinations.size() >= max_favorites:
			recipe_book.favorite_error(combination)
			MessageLayer.favorite_error("unavailable")
		elif recipe_book.favorite_combinations.has(combination):
			recipe_book.favorite_error(combination)
			MessageLayer.favorite_error("already_favorited")
		else:
			if play_sfx:
				AudioManager.play_sfx("apply_favorite")
			recipe_book.favorite_combinations.append(combination)
			if battle:
				battle.add_favorite(combination, recipe_book.is_mastered(combination))
	else:
		recipe_book.favorite_combinations.erase(combination)
		if battle:
			battle.remove_favorite(combination)


func add_all_possible_failed_combinations(reagent_matrix):
	for matrix in ReagentManager.get_all_substitution_matrices(reagent_matrix):
		if not failed_combinations.has(matrix):
			failed_combinations.append(matrix)


func thanks_for_playing():
	Steam.set_rich_presence("#PostMortem")
	Steam.set_rich_presence("#PostMortem")
	FileManager.delete_run_file()
	$PauseScreen.set_block_pause(true)
	var scene
	if not Debug.is_demo:
		var times_finished = Profile.get_stat("times_finished")
		assert(times_finished.has(player.player_class.name), "Not a valid class name: " + str(player.player_class.name))
		assert(times_finished[player.player_class.name].has(difficulty), "Not a valid difficulty: " + str(difficulty))
		times_finished[player.player_class.name][difficulty] += 1
		Profile.set_stat("times_finished", times_finished)
		scene = load("res://game/ui/Ending.tscn").instance()
	else:
		scene = load("res://game/ui/ThanksScreenDemo.tscn").instance()
	add_child(scene)
	scene.player = player


func _on_Combination_fully_discovered(combination: Combination, source: String):
	possible_rewarded_combinations.erase(combination)
	if source != "shop" and source != "new_game" and source != "debug":
		player.call_artifacts("discover_recipe", {"player": player, "source": source})
	player.increase_stat("recipes_discovered")

func _on_map_node_selected(node: MapNode):
	if not node.type in [MapNode.ENEMY, MapNode.ELITE, MapNode.BOSS,
			MapNode.SHOP, MapNode.REST, MapNode.SMITH, MapNode.LABORATORY,
			MapNode.TREASURE, MapNode.EVENT]:
		return
	
	TooltipLayer.clean_tooltips()
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	map.disable()
	
	if node.type == MapNode.SHOP:
		open_shop()
	elif node.type == MapNode.REST:
		open_rest(node, player)
	elif node.type == MapNode.SMITH:
		open_smith(node, player)
	elif node.type == MapNode.LABORATORY:
		open_lab(node, player)
	elif node.type == MapNode.TREASURE:
		open_treasure(node, player)
	elif node.type == MapNode.EVENT:
		current_node = node
		open_event(node)
	else: # MapNode.ENEMY, MapNode.ELITE, MapNode.BOSS
		current_node = node
		if not Profile.get_tutorial("first_battle") and node.type == MapNode.ENEMY and floor_level == 1:
			node.encounter = EncounterManager.get_tutorial_encounter()
		new_battle(node.encounter)


func _on_Battle_won():
	var rewarded_combinations := []
	battle.disable_player()
	
	if battle.is_boss:
		var size = min(player.grid_size + 1, player.GRID_SIZES.back())
		var indices = range(combinations[size].size())
		indices.shuffle()
		for _i in RECIPES_REWARDED_PER_BATTLE:
			var index = indices.pop_front()
			rewarded_combinations.append(combinations[size][index])
	else:
		possible_rewarded_combinations.shuffle()
		for i in RECIPES_REWARDED_PER_BATTLE:
			if i < possible_rewarded_combinations.size():
				rewarded_combinations.append(possible_rewarded_combinations[i])
			else:
				rewarded_combinations.append(null)
	
	battle.show_victory_screen(rewarded_combinations)


func _on_Battle_finished(is_boss, is_elite, is_final_boss):
	time_running = false
	if not is_final_boss:
		Transition.begin_transition()
		yield(Transition, "screen_dimmed")
		
		battle.queue_free()
		battle = null
		recipe_book.change_state(RecipeBook.States.MAP)
		
		Transition.end_transition()
	
	var should_save = true
	if is_boss:
		player.set_floor_stat("percentage_done", map.get_done_percentage(true))
		map.queue_free()
		floor_level += 1
		if floor_level >= 1 and floor_level <= 3:
			Steam.set_rich_presence(tr("FLOOR_NAME_" + str(floor_level)), "floor")
		if not is_final_boss:
			if floor_level == 2:
				AchievementManager.unlock("reached_floor2")
				Profile.unlock_background("toxicologist")
			elif floor_level == 3:
				AchievementManager.unlock("reached_floor3")
				Profile.unlock_background("steadfast")
			
			play_map_bgm()
			create_level(floor_level)
			$Player.level_up()
			player_info.update_values(player)
			player_info.show()
			yield(Transition, "finished")
			time_running = true
			Steam.set_rich_presence("#InMap")
			
		else:
			should_save = false
#			enable_map()
			player.cur_level += 1
			player.increase_stat("time", time_of_run)
			thanks_for_playing()
	else:
		play_map_bgm()
		if not is_elite:
			player.increase_floor_stat("normal_encounters_finished")
		else:
			player.increase_floor_stat("elite_encounters_finished")
		enable_map()
		current_node.set_type(MapNode.EMPTY)
		player.set_floor_stat("percentage_done", map.get_done_percentage())
		map.reveal_paths(current_node)
		current_node = null
		yield(Transition, "finished")
		time_running = true
	
	if should_save:
		FileManager.save_game()


func _on_new_combinations_seen(new_combinations: Array):
	for combination in new_combinations:
		if combination:
			player.discover_combination(combination)
			player.saw_recipe(combination.recipe.id)


func _on_combination_rewarded(combination):
	recipe_book.update_combination(combination)


func _on_combination_studied(combination):
	times_recipe_made[combination.recipe.id] = mastery_threshold(combination)
	recipe_book.unlock_mastery(combination)
	recipe_book.update_combination(combination)


func _on_Battle_combination_made(reagent_matrix: Array, reagent_list: Array):
	var combination = get_combination_in_grid(reagent_matrix, battle.grid.grid_size)
	if combination:
		AudioManager.play_sfx("combine_success")
		#Fix unstable reagents
		for reagent in reagent_list:
			if reagent.unstable:
				reagent.toggle_unstable()
		# Not using AudioManager.get_sfx_duration("combine_success") since it has some silence at the end
		yield(get_tree().create_timer(1.0), "timeout")
		make_combination("battle", combination, extract_boost_effects(reagent_list))
	else:
		AudioManager.play_sfx("combine_fail")
		battle.apply_effects(["combination_failure"], reagent_list)
		
		add_all_possible_failed_combinations(reagent_matrix)


func _on_Battle_grid_modified(reagent_matrix: Array):
	if battle.player_disabled:
		return
	var combination = get_combination_in_grid(reagent_matrix, battle.grid.grid_size)
	if combination and not combination.discovered:
		combination = null
	elif not combination and (failed_combinations.has(reagent_matrix) or is_single_reagent(reagent_matrix)):
		combination = "failure"
	
	var mastered = false if not combination or (combination is String and combination == "failure") else recipe_book.is_mastered(combination)
	battle.display_name_for_combination(combination, mastered)


func _on_Laboratory_combination_made(reagent_matrix: Array, grid_size : int):
	var combination = get_combination_in_grid(reagent_matrix, grid_size)
	if combination:
		AudioManager.play_sfx("combine_success")
		make_combination("laboratory", combination, {}, false)
		lab.combination_success(combination)
	else:
		AudioManager.play_sfx("combine_fail")
		combination = "failure"
		add_all_possible_failed_combinations(reagent_matrix)
		lab.combination_failed()
	
	lab.display_name_for_combination(combination)
	

func _on_Laboratory_grid_modified(reagent_matrix: Array, grid_size : int):
	var combination = get_combination_in_grid(reagent_matrix, grid_size)
	if combination and not combination.discovered:
		combination = null
	elif not combination and (failed_combinations.has(reagent_matrix) or is_single_reagent(reagent_matrix)):
		combination = "failure"
	
	lab.display_name_for_combination(combination)


func _on_Player_combination_discovered(combination, _index):
	recipe_book.add_combination(combination, mastery_threshold(combination))


func _on_RecipeBook_recipe_pressed(combination: Combination, should_autocomplete: bool):
	assert(battle.grid.grid_size >= combination.grid_size)
	recipe_book_toggle()
	battle.grid.clear_hints()
	if should_autocomplete:
		battle.disable_player()
		battle.autocomplete_grid(combination)
		yield(battle, "finished_autocomplete")
		battle.enable_player()
		#TODO: Blink restrain/restricted slots
	else:
		if not battle.grid.show_combination_hint(combination):
			AudioManager.play_sfx("error")
			#TODO: Blink restrain/restricted slots
		elif not Profile.get_tutorial("clicked_recipe"):
			TutorialLayer.start("clicked_recipe")
			yield(TutorialLayer, "tutorial_finished")
			Profile.set_tutorial("clicked_recipe", true)


func _on_RecipeBook_favorite_toggled(combination, button_pressed):
	favorite_combination(combination, button_pressed)


func _on_Shop_closed():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	shop.hide()
	enable_map()
	play_map_bgm()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	FileManager.save_run()


func _on_Shop_combination_bought(combination: Combination):
	recipe_book.update_combination(combination)


func _on_Shop_hint_bought(combination: Combination):
	recipe_book.update_combination(combination)


func _on_Rest_closed():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	rest.hide()
	enable_map()
	if current_node and is_instance_valid(current_node):
		map.reveal_paths(current_node)
		current_node = null
	play_map_bgm()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	FileManager.save_run()


func _on_Blacksmith_closed():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	smith.hide()
	enable_map()
	play_map_bgm()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	FileManager.save_run()


func _on_Laboratory_closed():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	recipe_book.change_state(RecipeBook.States.MAP)
	lab.hide()
	cur_lab_attempts = lab.get_attempts()
	enable_map()
	play_map_bgm()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	FileManager.save_run()


func _on_Treasure_closed():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	treasure.hide()
	enable_map()
	play_map_bgm()
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	FileManager.save_run()


func _on_EventDisplay_closed():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	hide_event()
	enable_map()
	play_map_bgm()
	map.reveal_paths(current_node)
	current_node = null
	
	player.set_floor_stat("percentage_done", map.get_done_percentage())
	
	Transition.end_transition()
	yield(Transition, "finished")
	time_running = true
	FileManager.save_run()


func _on_EventDisplay_event_spawned_battle(encounter):
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	hide_event()
	current_node = event_display.map_node
	new_battle(encounter, true)


func _on_EventDisplay_event_spawned_rest():
	Transition.begin_transition()
	time_running = false
	yield(Transition, "screen_dimmed")
	
	hide_event()
	current_node = event_display.map_node
	open_rest(event_display.map_node, player)


func _on_Debug_combinations_unlocked():
	if not Debug.recipes_unlocked:
		Debug.recipes_unlocked = true
		for grid_size in [2, 3, 4]:
			for combination in combinations[grid_size]:
				combination.discover_all_reagents("debug")
				recipe_book.add_combination(combination, mastery_threshold(combination))
				recipe_book.update_combination(combination)


func _on_Debug_floor_selected(floor_number: int):
	if battle:
		battle.queue_free()
		battle = null
	if map:
		map.queue_free()
	
	create_level(floor_number)
	player.set_level(floor_number)


func _on_Debug_test_map_creation():
	var total_time = 0
	var n = 100
	for i in n:
		var time = OS.get_ticks_msec()
		print("Creating map: " + str(i))
		create_level(3, true)
		var new_time = OS.get_ticks_msec()
		var elapsed_time = new_time - time
		print("Created map: " + str(i) + ". Time elapsed: " + str(elapsed_time) + "ms")
		total_time += elapsed_time
		
		#Allows Godot to free memory allocated to measure time more accurately
		yield(get_tree(), "idle_frame")
	print("Finished " + str(n) + " map creations in " + str(total_time) + "ms")
	print("Average time per map: " + str(float(total_time)/n) + "ms")


func _on_Debug_event_pressed(id: int):
	map.disable()
	var event = EventManager.get_event_by_id(id)
	if event.bgm != null:
		AudioManager.play_bgm(event.bgm)
	event_display.load_event(event, player)
	show_event()


func _on_Battle_update_recipes_display():
	recipe_book.reapply_tag_and_filters()


func _on_PlayerInfo_button_pressed():
	recipe_book_toggle()


func _on_RecipeBook_close():
	recipe_book_toggle()


func _on_Laboratory_recipe_toggle():
	recipe_book_toggle()


func _on_favorite_recipe(combination):
	favorite_combination(combination, true)
	recipe_book.set_favorite_button(combination, true, true)


func _on_player_reveal_map():
	map.reveal_all_paths()


func _on_Battle_block_pause(value):
	$PauseScreen.set_block_pause(value)


func _on_PauseButton_pressed():
	$PauseScreen.toggle_pause()
	if $PauseScreen.is_paused():
		shop.paused()
		smith.paused()


func _on_PauseButton_mouse_entered():
	AudioManager.play_sfx("hover_pause_button")


func _on_PauseButton_button_down():
	AudioManager.play_sfx("click_pause_button")


func _on_RecipeBook_recipe_pressed_lab(combination: Combination):
	assert(lab.grid.grid_size >= combination.grid_size)
	recipe_book_toggle()
	lab.grid.clear_hints()
	if not lab.grid.show_combination_hint(combination):
		AudioManager.play_sfx("error")


func _on_map_finished_revealing_map():
	player.set_floor_stat("percentage_done", map.get_done_percentage())


func _on_PauseScreen_exited_pause():
	timer.visible = Profile.get_option("show_timer")
	updateMapFog()
	shop.exited_pause()
	smith.exited_pause()


func _on_Battle_player_died():
	time_running = false
	set_process(false)
	player.increase_stat("time", time_of_run)
	Steam.set_rich_presence("#PostMortem")


func _on_PauseScreen_block_pause_update(value):
	$UI/PauseButton.set_blocked(value)


func _on_RecipeBook_update_favorite_mastery(combination):
	if battle:
		battle.update_favorite_mastery(combination)
