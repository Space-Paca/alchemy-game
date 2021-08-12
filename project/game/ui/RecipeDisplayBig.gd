extends TextureRect

onready var middle_container = $MarginContainer/VBoxContainer/HBoxContainer/Middle
onready var right_container = $MarginContainer/VBoxContainer/HBoxContainer/Right
onready var description = $MarginContainer/VBoxContainer/Description
onready var grid = $MarginContainer/VBoxContainer/HBoxContainer/Left/GridContainer
onready var title = $MarginContainer/VBoxContainer/Title
onready var reagent_list = $MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList
onready var left_column = $MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/LeftColumn
onready var right_column = $MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/RightColumn

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")
const REAGENT_SIZE = 50
const MASTERED_TEXTURE = preload("res://assets/images/ui/book/mastered_recipe_page.png")
const REAGENT_AMOUNT = preload("res://game/ui/ReagentAmountBig.tscn")
const MAX_REAGENT_COLUMN = 4

var combination : Combination

func set_combination(_combination: Combination):
	combination = _combination
	title.text = combination.recipe.name
	description.text = RecipeManager.get_description(combination.recipe)
	grid.columns = combination.grid_size
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = REAGENT.instance()
			reagent.rect_min_size = Vector2(REAGENT_SIZE, REAGENT_SIZE)
			reagent.set_mode("grid")
			grid.add_child(reagent)
			reagent.set_reagent(combination.known_matrix[i][j])
	
	if combination.discovered:
		right_container.queue_free()
		middle_container.queue_free()
	else:
		var columns := [left_column, right_column]
		var i := 0
		for reagent in combination.reagent_amounts:
			var reagent_amount = REAGENT_AMOUNT.instance()
# warning-ignore:integer_division
			columns[i / MAX_REAGENT_COLUMN].add_child(reagent_amount)
			reagent_amount.set_reagent(reagent)
			reagent_amount.set_amount(combination.reagent_amounts[reagent])
			i += 1


func update_combination():
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = grid.get_child(i*combination.grid_size + j)
			reagent.set_reagent(combination.known_matrix[i][j])
	
	if combination.discovered:
		if right_container and is_instance_valid(right_container):
			right_container.queue_free()
		if middle_container and is_instance_valid(middle_container):
			middle_container.queue_free()


func master_combination():
	title.text = tr(combination.recipe.name) + "+"
	description.text = RecipeManager.get_description(combination.recipe, true)
	texture = MASTERED_TEXTURE

func enable_tooltips():
	for reagent in grid.get_children():
		reagent.enable_tooltips()
	if left_column:
		for reagent in left_column.get_children():
			reagent.enable_tooltips()
	if right_column:
		for reagent in right_column.get_children():
			reagent.enable_tooltips()


func disable_tooltips():
	for reagent in grid.get_children():
		reagent.disable_tooltips()
	if left_column and is_instance_valid(left_column):
		for reagent in left_column.get_children():
			reagent.disable_tooltips()
	if right_column and is_instance_valid(right_column):
		for reagent in right_column.get_children():
			reagent.disable_tooltips()
