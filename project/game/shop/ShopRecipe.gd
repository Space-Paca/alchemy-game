extends Panel

onready var grid = $CenterContainer/VBoxContainer/CenterContainer/RecipeGrid
onready var name_label = $CenterContainer/VBoxContainer/RecipeName
onready var reagent_list = $CenterContainer/VBoxContainer/MarginContainer/ReagentList

const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")

var combination : Combination


func set_combination(_combination: Combination):
	var size = _combination.grid_size
	combination = _combination
	
	# NAME
	name_label.text = combination.recipe.name
	
	# GRID
	for i in range(size * size, grid.get_child_count()):
		grid.get_child(i).queue_free()
	for i in range(size):
		for j in range(size):
			var display = grid.get_child(i * size + j)
			display.set_reagent(combination.known_matrix[i][j])
	grid.columns = combination.grid_size
	
	# REAGENTS
	var reagent_count = {}
	for reagent in combination.recipe.reagents:
		if reagent in reagent_count:
			reagent_count[reagent] += 1
		else:
			reagent_count[reagent] = 1
	for reagent in reagent_count:
		var reagent_amount_display = REAGENT_AMOUNT.instance()
		reagent_list.add_child(reagent_amount_display)
		reagent_amount_display.set_reagent(reagent)
		reagent_amount_display.set_amount(reagent_count[reagent])
