extends Node

onready var player = $Player
onready var recipe_book = $BookLayer/RecipeBook

const BATTLE_SCENE = preload("res://game/battle/Battle.tscn")
const FLOOR_SCENE = preload("res://game/map/Floor.tscn")
const FLOOR_SIZE := [10, 20, 30]
const MAX_FLOOR = 3

var battle
var combinations := {}
var current_floor : Floor
var floor_level := 1
var times_recipe_made := {}


func _ready():
	randomize()
	create_combinations()
	create_floor(1)
	AudioManager.play_bgm("map")


func _input(event):
	if event.is_action_pressed("show_recipe_book"):
		recipe_book.toggle()


func create_combinations():
	for recipe in RecipeManager.recipes.values():
		var combination = Combination.new()
		combination.create_from_recipe(recipe)
		if combinations.has(combination.grid_size):
			(combinations[combination.grid_size] as Array).append(combination)
		else:
			combinations[combination.grid_size] = [combination]
		
		if player.known_recipes.has(recipe.name):
			recipe_book.add_combination(combination, player.known_recipes.find(recipe.name))
		
		print(combination.name, "\n", combination.matrix)


func create_floor(level: int):
	current_floor = FLOOR_SCENE.instance()
	current_floor.room_amount = FLOOR_SIZE[level - 1]
	current_floor.level = floor_level
	if current_floor.connect("room_entered", self, "_on_room_entered") != OK:
		print("create_floor: Error")
	add_child(current_floor)


func search_grid_for_combinations(reagent_matrix: Array):
	print(reagent_matrix)
	var grid_size = battle.grid.grid_size
	
	if check_combinations(grid_size, reagent_matrix):
		return
	
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
				
				if check_combinations(new_grid_size, new_matrix):
					print("Combination found; size = %d; position = (%d, %d)" %
							[new_grid_size, i_offset, j_offset])
					return
	
	print("No combinations found!")
	battle.apply_effects(["combination_failure"])


func check_combinations(grid_size: int, reagent_matrix: Array):
	print("check_combinations; grid_size: ", grid_size)
	print("reagent_matrix: ", reagent_matrix)
	
	if not combinations.has(grid_size):
		print("No recipes exist for grid with size ", grid_size)
		return false
	
	for combination in combinations[grid_size]:
		if reagent_matrix == (combination as Combination).matrix:
			prints((combination as Combination).recipe.name, "found")
			var recipe = (combination.recipe as Recipe)
			AudioManager.play_sfx("combine_success")
			battle.apply_effects(recipe.effects, recipe.effect_args)
			
			if not player.known_recipes.has(recipe.name):
				player.discover_combination(combination)
			
			if not times_recipe_made.has(recipe.name):
				times_recipe_made[recipe.name] = 1
			else:
				times_recipe_made[recipe.name] += 1
			
			return true
	
	return false


func new_battle(encounter: Encounter):
	assert(battle == null)
	battle = BATTLE_SCENE.instance()
	add_child(battle)
	battle.setup(player, encounter)
# warning-ignore:return_value_discarded
	battle.connect("combination_made", self, "_on_Battle_combination_made")
# warning-ignore:return_value_discarded
	battle.connect("won", self, "_on_Battle_won")
	
	recipe_book.create_hand(battle)


func should_autocomplete(combination: Combination) -> bool:
	return true
	if not times_recipe_made.has(combination.recipe.name):
		return false
	
	var threshold = min(10, 14 - combination.recipe.reagents.size())
	threshold = max(threshold, 2)
	
	return times_recipe_made[combination.recipe.name] > threshold


func _on_room_entered(room: Room):
	if room.type == Room.Type.MONSTER or room.type == Room.Type.BOSS:
		new_battle(room.encounter)
		current_floor.hide()


func _on_Battle_won(is_boss):
	battle = null
	recipe_book.remove_hand()
	
	if is_boss:
		current_floor.queue_free()
		floor_level += 1
		if floor_level <= MAX_FLOOR:
			create_floor(floor_level)
	else:
		current_floor.show()


func _on_Battle_combination_made(reagent_matrix: Array):
	search_grid_for_combinations(reagent_matrix)


func _on_Player_combination_discovered(combination, index):
	recipe_book.add_combination(combination, index)


func _on_RecipeBook_recipe_pressed(combination):
	recipe_book.toggle()
	if should_autocomplete(combination):
		battle.autocomplete_grid(combination)
	else:
		battle.grid.show_combination_hint(combination)
