extends Control

signal hovered(reagent_array)
signal unhovered()

onready var bg = $Background
onready var unknown_bg = $UnknownBG
onready var middle_container = $Background/MarginContainer/VBoxContainer/HBoxContainer/Middle
onready var right_container = $Background/MarginContainer/VBoxContainer/HBoxContainer/Right
onready var description = $Background/MarginContainer/VBoxContainer/Description
onready var memorization_progress = $Background/MemorizationProgress
onready var memorization_label = $Background/MemorizationLabel
onready var grid = $Background/MarginContainer/VBoxContainer/HBoxContainer/Left/GridContainer
onready var title = $Background/MarginContainer/VBoxContainer/Title
onready var left_column = $Background/MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/LeftColumn
onready var right_column = $Background/MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/RightColumn

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")
const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")
const RECIPE_BG = preload("res://assets/images/ui/book/recipe_page.png")
const RECIPE_MASTERED_BG = preload("res://assets/images/ui/book/mastered_recipe_page.png")
const MAX_REAGENT_COLUMN = 4
const HOVERED_SCALE = 1.05
const SCALE_SPEED = 5

var combination : Combination
var reagent_array := []
var filtered := true
var hovered := false


func _process(delta):
	if hovered:
		rect_scale.x = min(rect_scale.x + delta*SCALE_SPEED, HOVERED_SCALE)
		rect_scale.y = min(rect_scale.y + delta*SCALE_SPEED, HOVERED_SCALE)
	else:
		rect_scale.x = max(rect_scale.x - delta*SCALE_SPEED, 1)
		rect_scale.y = max(rect_scale.y - delta*SCALE_SPEED, 1)


func set_combination(_combination: Combination):
	combination = _combination
	reagent_array = combination.recipe.reagents
	title.text = combination.recipe.name
	description.text = RecipeManager.get_description(combination.recipe)
	grid.columns = combination.grid_size
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = REAGENT.instance()
			reagent.set_mode("grid")
			grid.add_child(reagent)
			reagent.set_reagent(combination.known_matrix[i][j])
	
	set_progress(combination.recipe.name)


func set_progress(recipe_name: String):
	var amount = Profile.known_recipes[recipe_name]["amount"]
	var threshold = Profile.known_recipes[recipe_name]["memorized_threshold"]
	
	if amount == -1:
		bg.hide()
		unknown_bg.show()
	else:
		memorization_label.text = "Memorization " + str(amount) + "/" + str(threshold)
		memorization_progress.max_value = threshold
		memorization_progress.value = amount


func enable_tooltips():
	for reagent_amount in grid.get_children():
		reagent_amount.enable_tooltips()
	
	if left_column:
		for reagent_amount in left_column.get_children():
			reagent_amount.enable_tooltips()
	if right_column:
		for reagent_amount in right_column.get_children():
			reagent_amount.enable_tooltips()


func disable_tooltips():
	for reagent_amount in grid.get_children():
		reagent_amount.disable_tooltips()


func _on_Panel_mouse_entered():
	hovered = true
	AudioManager.play_sfx("hover_recipe_button")
	emit_signal("hovered", reagent_array)


func _on_Panel_mouse_exited():
	hovered = false
	emit_signal("unhovered")
