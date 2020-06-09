extends TextureRect

signal chosen

onready var grid = $CenterContainer/RecipeGrid
onready var name_label = $NameBanner/RecipeName
onready var description_label = $DescriptionLabel
onready var reagent_list = $ReagentContainer/ReagentList
onready var choose_button = $ChooseButton

var combination : Combination
var discover_all = false

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
	var i = 0
	for reagent in combination.reagent_amounts:
#		var reagent_amount_display = REAGENT_AMOUNT.instance()
#		reagent_list.add_child(reagent_amount_display)
#		reagent_amount_display.set_reagent(reagent)
#		reagent_amount_display.set_amount(combination.reagent_amounts[reagent])
		for j in combination.reagent_amounts[reagent]:
			reagent_list.get_child(i).texture = ReagentDB.get_from_name(reagent).image
			i += 1


func _on_ChooseButton_pressed():
	if not discover_all:
		var amount = int(ceil(combination.unknown_reagent_coords.size() / 2.0))
		combination.discover_reagents(amount)
	else:
		combination.discover_all_reagents()
	
	if not combination.discovered:
		AudioManager.play_sfx("discover_clue_recipe")
	else:
		AudioManager.play_sfx("discover_new_recipe")
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var display = grid.get_child(i* combination.grid_size + j)
			display.set_reagent(combination.known_matrix[i][j])
	
	choose_button.hide()
	emit_signal("chosen", self)
