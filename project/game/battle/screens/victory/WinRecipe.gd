extends Panel

signal chosen

onready var grid = $CenterContainer/VBoxContainer/CenterContainer/RecipeGrid
onready var name_label = $CenterContainer/VBoxContainer/RecipeName
onready var description_label = $CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/DescriptionContainer/DescriptionLabel
onready var reagent_list = $CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/ReagentContainer/ReagentList
onready var choose_button = $CenterContainer/VBoxContainer/ChooseButton

const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")

var combination : Combination


func set_combination(_combination: Combination):
	var size = _combination.grid_size
	combination = _combination
	
	# NAME
	name_label.text = combination.recipe.name
	
	# DESCRIPTION
	description_label.text = combination.recipe.description
	
	# GRID
	for i in range(size * size, grid.get_child_count()):
		grid.get_child(i).visible = false
	for i in range(size):
		for j in range(size):
			var display = grid.get_child(i*size + j)
			display.set_reagent(combination.known_matrix[i][j])
			display.visible = true
	grid.columns = combination.grid_size
	
	# REAGENTS
	for reagent in combination.reagent_amounts:
		var reagent_amount_display = REAGENT_AMOUNT.instance()
		reagent_list.add_child(reagent_amount_display)
		reagent_amount_display.set_reagent(reagent)
		reagent_amount_display.set_amount(combination.reagent_amounts[reagent])


func _on_ChooseButton_pressed():
	var amount = int(ceil(combination.unknown_reagent_coords.size() / 2.0))
	combination.discover_reagents(amount)
	
	if not combination.discovered:
		AudioManager.play_sfx("discover_clue_recipe")
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var display = grid.get_child(i* combination.grid_size + j)
			display.set_reagent(combination.known_matrix[i][j])
	
	choose_button.hide()
	emit_signal("chosen", self)
