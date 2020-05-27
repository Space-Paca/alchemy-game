extends Node

onready var player = $Player
onready var recipe_book = $BookLayer/RecipeBook
onready var shop = $Shop

const BATTLE_SCENE = preload("res://game/battle/Battle.tscn")
const FLOOR_SCENE = preload("res://game/map/Floor.tscn")
const FLOOR_SIZE := [10, 20, 30]
const MAX_FLOOR = 3
const RECIPES_REWARDED_PER_BATTLE = 3

var battle
var combinations := {}
var current_floor : Floor
var floor_level := 1
var times_recipe_made := {}
var favorite_combinations := []
var max_favorites := 8
var possible_rewarded_combinations := []

var debug_recipes_unlock = false


func _ready():
	randomize()
	create_combinations()
	create_floor(1)
	AudioManager.play_bgm("map")


func _input(event):
	if event.is_action_pressed("show_recipe_book"):
		if not (battle and battle.player_disabled):
			recipe_book.toggle_visibility()
	elif event.is_action_pressed("ui_home"):
		if not debug_recipes_unlock:
			debug_recipes_unlock = true
			for grid_size in [2, 3, 4]:
				for combination in combinations[grid_size]:
					combination.discover_all_reagents()
					recipe_book.add_combination(combination,
							player.known_recipes.bsearch(combination.recipe.name))


func create_combinations():
	for recipe in RecipeManager.recipes.values():
		var combination = Combination.new()
		combination.create_from_recipe(recipe)
		combination.connect("fully_discovered", self, "_on_Combination_fully_discovered")
		
		if combinations.has(combination.grid_size):
			(combinations[combination.grid_size] as Array).append(combination)
		else:
			combinations[combination.grid_size] = [combination]
		
		if player.known_recipes.has(recipe.name):
			combination.discover_all_reagents()
			recipe_book.add_combination(combination, player.known_recipes.find(recipe.name))


func create_floor(level: int):
	current_floor = FLOOR_SCENE.instance()
	current_floor.room_amount = FLOOR_SIZE[level - 1]
	current_floor.level = floor_level
	if current_floor.connect("room_entered", self, "_on_room_entered") != OK:
		push_error("create_floor: Error")
		assert(false)
	add_child(current_floor)
	
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if combination.recipe.floor_sold_in == floor_level and not\
					player.known_recipes.has(combination.recipe.name):
				possible_rewarded_combinations.append(combination)
	
	setup_shop()


func setup_shop():
	var shop_combinations = []
	possible_rewarded_combinations.shuffle()
	for i in range(shop.sold_amount):
		if i < possible_rewarded_combinations.size():
			shop_combinations.append(possible_rewarded_combinations[i])
		else:
			shop_combinations.append(null)
	
	shop.player = player
	shop.set_combinations(shop_combinations)


func get_combination_in_grid(reagent_matrix: Array) -> Combination:
	var grid_size = battle.grid.grid_size
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
	
	for combination in combinations[grid_size]:
		if reagent_matrix == (combination as Combination).matrix:
			return combination
	
	return null


func make_combination(combination: Combination):
	var recipe := combination.recipe
	battle.apply_effects(recipe.effects, recipe.effect_args, recipe.destroy_reagents)
	
	if not player.known_recipes.has(recipe.name):
		MessageLayer.add_message("Oh yeah! I discovered a new recipe")
		combination.discover_all_reagents()
		player.discover_combination(combination)
		shop.update_combinations()
	elif not combination.discovered:
		combination.discover_all_reagents()
		recipe_book.update_combination(combination)
		shop.update_combinations()
	
	if not times_recipe_made.has(recipe.name):
		times_recipe_made[recipe.name] = 1
	else:
		times_recipe_made[recipe.name] += 1
	
	if should_unlock_mastery(combination):
		recipe_book.unlock_mastery(combination)
	


func should_unlock_mastery(combination: Combination) -> bool:
	if not times_recipe_made.has(combination.recipe.name):
		return false
	
	var threshold = min(10, 14 - combination.recipe.reagents.size())
	threshold = max(threshold, 2)
	
	return times_recipe_made[combination.recipe.name] > threshold


func new_battle(encounter: Encounter):
	assert(battle == null)
	battle = BATTLE_SCENE.instance()
	add_child(battle)
	
	battle.setup(player, encounter, favorite_combinations)
# warning-ignore:return_value_discarded
	battle.connect("combination_made", self, "_on_Battle_combination_made")
# warning-ignore:return_value_discarded
	battle.connect("won", self, "_on_Battle_won")
# warning-ignore:return_value_discarded
	battle.connect("finished", self, "_on_Battle_finished")
# warning-ignore:return_value_discarded
	battle.connect("combination_rewarded", self, "_on_Battle_combination_rewarded")
# warning-ignore:return_value_discarded
	battle.connect("grid_modified", self, "_on_Battle_grid_modified")
	
	recipe_book.create_hand(battle)


func open_shop():
	AudioManager.play_bgm("shop")
	current_floor.hide()
	shop.update_currency()
	shop.show()
	
	for shop_recipe in shop.recipes:
		player.discover_combination(shop_recipe.combination)


func _on_Combination_fully_discovered(combination: Combination):
	possible_rewarded_combinations.erase(combination)


func _on_room_entered(room: Room):
	if room.type == Room.Type.MONSTER or room.type == Room.Type.BOSS or room.type == Room.Type.ELITE:
		new_battle(room.encounter)
		current_floor.hide()
	elif room.type == Room.Type.SHOP:
		open_shop()


func _on_Battle_won():
	var rewarded_combinations := []
	possible_rewarded_combinations.shuffle()
	for i in range(RECIPES_REWARDED_PER_BATTLE):
		if i < possible_rewarded_combinations.size():
			rewarded_combinations.append(possible_rewarded_combinations[i])
		else:
			rewarded_combinations.append(null)
	
	for combination in rewarded_combinations:
		if combination:
			player.discover_combination(combination)
	
	battle.show_victory_screen(rewarded_combinations)


func _on_Battle_finished(is_boss):
	battle = null
	recipe_book.remove_hand()
	
	if is_boss:
		current_floor.queue_free()
		floor_level += 1
		if floor_level <= MAX_FLOOR:
			create_floor(floor_level)
			$Player.level_up()
	else:
		current_floor.show()


func _on_Battle_combination_rewarded(combination):
	recipe_book.update_combination(combination)


func _on_Battle_combination_made(reagent_matrix: Array, reagent_list: Array):
	var combination = get_combination_in_grid(reagent_matrix)
	if combination:
		AudioManager.play_sfx("combine_success")
		make_combination(combination)
	else:
		AudioManager.play_sfx("combine_fail")
		battle.apply_effects(["combination_failure"], reagent_list)


func _on_Battle_grid_modified(reagent_matrix: Array):
	var combination = get_combination_in_grid(reagent_matrix)
	if combination and not combination.discovered:
		combination = null
	
	battle.display_name_for_combination(combination)


func _on_Player_combination_discovered(combination, index):
	recipe_book.add_combination(combination, index)


func _on_RecipeBook_recipe_pressed(combination: Combination, mastery_unlocked: bool):
	assert(battle.grid.grid_size >= combination.grid_size)
	recipe_book.toggle_visibility()
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
	current_floor.show()
	AudioManager.play_bgm("map")


func _on_Shop_combination_bought(combination: Combination):
	player.discover_combination(combination)


func _on_Shop_hint_bought(combination: Combination):
	if not player.known_recipes.has(combination.recipe.name):
		player.discover_combination(combination)
	else:
		recipe_book.update_combination(combination)
