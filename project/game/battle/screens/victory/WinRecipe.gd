extends TextureRect

signal chosen

onready var grid = $CenterContainer/RecipeGrid
onready var name_label = $NameBanner/RecipeName
onready var description_label = $DescriptionLabel
onready var reagent_list = $ReagentContainer/ReagentList
onready var choose_button = $ChooseButton
onready var hint_label = $ChooseButton/Label

var combination : Combination
var discover_all = false

func _ready():
	for reagent in grid.get_children():
		reagent.set_mode("grid")


func set_combination(_combination: Combination):
	var size = _combination.grid_size
	combination = _combination
	
	# NAME
	name_label.text = combination.recipe.name
	
	# DESCRIPTION
	description_label.text = RecipeManager.get_description(combination.recipe)
	
	# BUTTON TEXT
	if discover_all or combination.hints >= 2:
		hint_label.text = "Learn"
		discover_all = true
	
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
		for j in combination.reagent_amounts[reagent]:
			reagent_list.get_child(i).texture = ReagentDB.get_from_name(reagent).image
			i += 1


func disable_button():
	choose_button.disabled = true


func enable_button():
	choose_button.disabled = false


func _on_ChooseButton_pressed():
	if not discover_all:
		combination.get_hint(2)
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
