extends Node

onready var player = $Player
onready var recipe_book = $BookLayer/RecipeBook
onready var shop = $Shop
onready var rest = $Rest
onready var lab = $Laboratory
onready var smith = $Blacksmith
onready var treasure = $Treasure

const BATTLE_SCENE = preload("res://game/battle/Battle.tscn")
const MAP_SCENE = preload("res://game/map/Map.tscn")
const RECIPES_REWARDED_PER_BATTLE = 3

var battle
var combinations := {}
var failed_combinations := []
var floor_level := 1
var times_recipe_made := {}
var favorite_combinations := []
var max_favorites := 8
var possible_rewarded_combinations := []
var map : Map
var current_node : MapNode
var laboratory_attempts = [60,8,10]
var cur_lab_attempts


func _ready():
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("combinations_unlocked", self, "_on_Debug_combinations_unlocked")
# warning-ignore:return_value_discarded
	Debug.connect("floor_selected", self, "_on_Debug_floor_selected")
	
# warning-ignore:return_value_discarded
	rest.connect("combination_rewarded", self, "_on_combination_rewarded")

# warning-ignore:return_value_discarded
	lab.connect("combination_made", self, "_on_Laboratory_combination_made")
# warning-ignore:return_value_discarded
	lab.connect("grid_modified", self, "_on_Laboratory_grid_modified")
	
	randomize()
	create_combinations()
	
	if Debug.floor_to_go != -1:
		floor_level = Debug.floor_to_go
		player.set_level(floor_level)
	
	create_level(floor_level)
	
	play_map_bgm()

func _input(event):
	if event.is_action_pressed("show_recipe_book"):
		if not (battle and battle.player_disabled):
			recipe_book_toggle()

func play_map_bgm():
	AudioManager.play_bgm("map" + str(floor_level))

func create_combinations():
	for recipe in RecipeManager.recipes.values():
		var combination = Combination.new()
		combination.create_from_recipe(recipe, combinations)
		combination.connect("fully_discovered", self, "_on_Combination_fully_discovered")
		
		if combinations.has(combination.grid_size):
			(combinations[combination.grid_size] as Array).append(combination)
		else:
			combinations[combination.grid_size] = [combination]
		
		if player.known_recipes.has(recipe.name):
			combination.discover_all_reagents()
			recipe_book.add_combination(combination, player.known_recipes.find(recipe.name))


func create_level(level: int):
	EncounterManager.set_random_encounter_pool(level)
	
	# MAP
	map = MAP_SCENE.instance()
	add_child(map)
	match level:
		1:
			# ( *∀*)y─┛
			#  ______________
			# (̅_̅_̅_̅(̅_̅_̅_̅_̅_̅_̅_̅_̅̅_̅()ڪے~
			map.create_map(4, 2, 0)
		2:
			map.create_map(6, 3, 0)
		3:
			map.create_map(8, 4, 0)
		var invalid:
			assert(false, str("Invalid level: ", invalid))
	map.set_level(level)
	map.connect("map_node_pressed", self, "_on_map_node_selected")
	
	# SHOP
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if combination.recipe.floor_sold_in == level and not\
					player.known_recipes.has(combination.recipe.name):
				possible_rewarded_combinations.append(combination)
	
	setup_shop()
	
	#LAB
	cur_lab_attempts = laboratory_attempts[level - 1]

func get_incomplete_combinations():
	var incomplete_combinations = []
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if player.known_recipes.has(combination.recipe.name) and not combination.discovered:
				incomplete_combinations.append(combination)
	
	return incomplete_combinations


func setup_shop():
	var shop_combinations = []
	possible_rewarded_combinations.shuffle()
	for i in range(shop.sold_amount):
		if i < possible_rewarded_combinations.size():
			shop_combinations.append(possible_rewarded_combinations[i])
		else:
			shop_combinations.append(null)
	
	shop.setup(shop_combinations, player)


func get_combination_in_grid(reagent_matrix: Array, grid_size : int) -> Combination:
	var grid_combination = get_combination_in_matrix(grid_size, reagent_matrix)
	
	if grid_combination:
		return grid_combination
	
	var new_grid_size = grid_size
	while new_grid_size > 2:
		new_grid_size -= 1
		var new_matrix = []
		for _i in range(new_grid_size):
			var line = []
			for _j in range(new_grid_size):
				line.append(null)
			new_matrix.append(line)
		
		for i_offset in range(grid_size - new_grid_size + 1):
			for j_offset in range(grid_size - new_grid_size + 1):
				
				for i in range(new_grid_size):
					for j in range(new_grid_size):
						new_matrix[i][j] = reagent_matrix[i+i_offset][j+j_offset]
				
				grid_combination = get_combination_in_matrix(new_grid_size, new_matrix)
				if grid_combination:
					return grid_combination
	
	return null


func get_combination_in_matrix(grid_size: int, reagent_matrix: Array) -> Combination:
	if not combinations.has(grid_size):
		print("No recipes exist for grid with size ", grid_size)
		return null
	
	var viewed_matrices = [reagent_matrix]
	var to_try_matrices = [reagent_matrix]
	while(not to_try_matrices.empty()):
		var matrix = to_try_matrices.pop_front()
		var combination = try_matrix(grid_size, matrix)
		if combination:
			return combination
		for new_matrix in downgrade_matrix(matrix):
			if viewed_matrices.find(new_matrix) == -1:
				viewed_matrices.append(new_matrix)
				to_try_matrices.append(new_matrix)

	return null

func try_matrix(grid_size: int, reagent_matrix: Array):
	for combination in combinations[grid_size]:
		if reagent_matrix == (combination as Combination).matrix:
			return combination
	
	return null

#Return an array of all possible combinations of given reagent_matrix downgrading just one reagent
func downgrade_matrix(matrix):
	var downgraded_matrices = []
	for i in range(0, matrix.size()):
		for j in range(0, matrix[i].size()):
			var reagent = matrix[i][j]
			if reagent:
				var reagent_data = ReagentManager.get_data(reagent)
				for sub_reagent in reagent_data.substitute:
					var new_matrix = matrix.duplicate(true)
					new_matrix[i][j] = sub_reagent
					downgraded_matrices.append(new_matrix)
	
	return downgraded_matrices

func make_combination(combination: Combination, boost_effects: Dictionary, apply_effects := true):
	var recipe := combination.recipe
	
	if not player.known_recipes.has(recipe.name) or not combination.discovered:
		combination.discover_all_reagents()
		player.discover_combination(combination, true)
		shop.update_combinations()
		MessageLayer.new_recipe_discovered(combination)
		
		if battle:
			battle.disable_elements()
		yield(MessageLayer, "continued")
		if battle:
			battle.enable_elements()
	
	if apply_effects:
		if not times_recipe_made.has(recipe.name):
			times_recipe_made[recipe.name] = 1
		else:
			times_recipe_made[recipe.name] += 1
		
		if not recipe_book.is_mastered(combination) and should_unlock_mastery(combination):
			recipe_book.unlock_mastery(combination)
			if battle:
				battle.disable_elements()
			yield(MessageLayer, "continued")
			if battle:
				battle.enable_elements()
	
		if recipe_book.is_mastered(combination):
			battle.apply_effects(recipe.master_effects, recipe.master_effect_args, recipe.master_destroy_reagents, boost_effects)
		else:
			battle.apply_effects(recipe.effects, recipe.effect_args, recipe.destroy_reagents, boost_effects)
		
	elif not times_recipe_made.has(recipe.name):
		times_recipe_made[recipe.name] = 0


func should_unlock_mastery(combination: Combination) -> bool:
	if not times_recipe_made.has(combination.recipe.name):
		return false
	
	var threshold = min(10, 18 - combination.recipe.reagents.size() - 3*combination.recipe.destroy_reagents.size() - 2*combination.recipe.grid_size)
	threshold = max(threshold, 2)
	
	return times_recipe_made[combination.recipe.name] > threshold


func new_battle(encounter: Encounter):
	assert(battle == null)
	battle = BATTLE_SCENE.instance()
	add_child(battle)
	
	battle.setup(player, encounter, favorite_combinations, floor_level)
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
	
	recipe_book.create_hand(battle)


func open_shop():
	AudioManager.play_bgm("shop")
	map.hide()
	shop.update_currency()
	shop.update_reagents()
	shop.show()


func open_rest(room, _player):
	AudioManager.play_bgm("rest")
	rest.setup(room, _player, get_incomplete_combinations())
	rest.show()
	map.hide()


func open_smith(room, _player):
	AudioManager.play_bgm("blacksmith")
	smith.setup(room, _player)
	smith.show()
	map.hide()

func open_lab(room, _player):
	AudioManager.play_bgm("laboratory")
	lab.setup(room, _player, cur_lab_attempts)
	lab.show()
	map.hide()

func open_treasure(room, _player):
	AudioManager.play_bgm("treasure")
	treasure.setup(room, _player, floor_level)
	treasure.show()
	map.hide()


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
			var effect = ReagentDB.get_from_name(reagent.type).effect.upgraded_boost
			effects[effect.type] += effect.value
	return effects

func recipe_book_toggle():
	var visible = recipe_book.toggle_visibility()
	if visible:
		recipe_book.update_player_bag(player.bag)

func thanks_for_playing():
	var scene = load("res://game/ui/ThanksScreen.tscn").instance()
	add_child(scene)


func _on_Combination_fully_discovered(combination: Combination):
	possible_rewarded_combinations.erase(combination)


func _on_map_node_selected(node:MapNode):
	if node.type in [MapNode.ENEMY, MapNode.ELITE, MapNode.BOSS]:
		current_node = node
		new_battle(node.encounter)
		map.hide()
		node.set_type(MapNode.EMPTY)
	elif node.type == MapNode.SHOP:
		open_shop()
	elif node.type == MapNode.REST:
		open_rest(node, player)
	elif node.type == MapNode.SMITH:
		open_smith(node, player)
	elif node.type == MapNode.LABORATORY:
		open_lab(node, player)
	elif node.type == MapNode.TREASURE:
		open_treasure(node, player)


func _on_Battle_won():
	var rewarded_combinations := []
	
	if battle.is_boss:
		var size = min(player.grid_size + 1, player.GRID_SIZES.back())
		var indices = range(combinations[size].size())
		indices.shuffle()
		for i in RECIPES_REWARDED_PER_BATTLE:
			rewarded_combinations.append(combinations[size][i])
	else:
		possible_rewarded_combinations.shuffle()
		for i in RECIPES_REWARDED_PER_BATTLE:
			if i < possible_rewarded_combinations.size():
				rewarded_combinations.append(possible_rewarded_combinations[i])
			else:
				rewarded_combinations.append(null)
	
	battle.show_victory_screen(rewarded_combinations)


func _on_Battle_finished(is_boss):
	battle = null
	recipe_book.remove_hand()
	
	if is_boss:
		map.queue_free()
		floor_level += 1
		if floor_level <= Debug.MAX_FLOOR:
			create_level(floor_level)
			$Player.level_up()
		else:
			map.show()
			thanks_for_playing()
	else:
		map.show()
		map.reveal_paths(current_node)


func _on_new_combinations_seen(new_combinations: Array):
	for combination in new_combinations:
		if combination:
			player.discover_combination(combination)


func _on_combination_rewarded(combination):
	recipe_book.update_combination(combination)


func _on_Battle_combination_made(reagent_matrix: Array, reagent_list: Array):
	var combination = get_combination_in_grid(reagent_matrix, battle.grid.grid_size)
	if combination:
		AudioManager.play_sfx("combine_success")
		#Fix unstable reagents
		for reagent in reagent_list:
			if reagent.unstable:
				reagent.toggle_unstable()
		make_combination(combination, extract_boost_effects(reagent_list))
	else:
		AudioManager.play_sfx("combine_fail")
		battle.apply_effects(["combination_failure"], reagent_list)

		if not failed_combinations.has(reagent_matrix):
			failed_combinations.append(reagent_matrix)


func _on_Battle_grid_modified(reagent_matrix: Array):
	if battle.player_disabled:
		return
	var combination = get_combination_in_grid(reagent_matrix, battle.grid.grid_size)
	if combination and not combination.discovered:
		combination = null
	elif not combination and failed_combinations.has(reagent_matrix):
		combination = "failure"
	
	battle.display_name_for_combination(combination)


func _on_Laboratory_combination_made(reagent_matrix: Array, grid_size : int):
	var combination = get_combination_in_grid(reagent_matrix, grid_size)
	if combination:
		AudioManager.play_sfx("combine_success")
		make_combination(combination, {}, false)
		lab.combination_success()
	else:
		AudioManager.play_sfx("combine_fail")

		if not failed_combinations.has(reagent_matrix):
			failed_combinations.append(reagent_matrix)
		lab.combination_failed()
	

func _on_Laboratory_grid_modified(reagent_matrix: Array, grid_size : int):
	var combination = get_combination_in_grid(reagent_matrix, grid_size)
	if combination and not combination.discovered:
		combination = null
	elif not combination and failed_combinations.has(reagent_matrix):
		combination = "failure"
	
	lab.display_name_for_combination(combination)


func _on_Player_combination_discovered(combination, index):
	recipe_book.add_combination(combination, index)


func _on_RecipeBook_recipe_pressed(combination: Combination, mastery_unlocked: bool):
	assert(battle.grid.grid_size >= combination.grid_size)
	recipe_book_toggle()
	if mastery_unlocked:
		battle.autocomplete_grid(combination)
	else:
		battle.grid.show_combination_hint(combination)


func _on_RecipeBook_favorite_toggled(combination, button_pressed):
	if button_pressed:
		if favorite_combinations.size() >= max_favorites:
			recipe_book.favorite_error(combination)
		else:
			AudioManager.play_sfx("apply_favorite")
			favorite_combinations.append(combination)
			if battle:
				battle.add_favorite(combination)
	else:
		favorite_combinations.erase(combination)
		if battle:
			battle.remove_favorite(combination)


func _on_Shop_closed():
	shop.hide()
	map.show()
	play_map_bgm()


func _on_Shop_combination_bought(combination: Combination):
	recipe_book.update_combination(combination)


func _on_Shop_hint_bought(combination: Combination):
	recipe_book.update_combination(combination)


func _on_Debug_combinations_unlocked():
	if not Debug.recipes_unlocked:
		Debug.recipes_unlocked = true
		for grid_size in [2, 3, 4]:
			for combination in combinations[grid_size]:
				combination.discover_all_reagents()
				recipe_book.add_combination(combination,
						player.known_recipes.bsearch(combination.recipe.name))
				recipe_book.update_combination(combination)


func _on_Debug_floor_selected(floor_number: int):
	if battle:
		battle.queue_free()
		battle = null
	if map:
		map.queue_free()
	
	create_level(floor_number)
	player.set_level(floor_number)


func _on_Rest_closed():
	rest.hide()
	map.show()
	play_map_bgm()


func _on_Blacksmith_closed():
	smith.hide()
	map.show()
	play_map_bgm()


func _on_Laboratory_closed():
	lab.hide()
	cur_lab_attempts = lab.get_attempts()
	map.show()
	play_map_bgm()


func _on_Treasure_closed():
	treasure.hide()
	map.show()
	play_map_bgm()
