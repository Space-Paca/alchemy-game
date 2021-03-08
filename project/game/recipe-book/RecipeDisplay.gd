extends Control

signal hovered(reagent_array)
signal unhovered()
signal pressed(combination, mastery_unlocked)
signal favorite_toggled(combination, button_pressed)

onready var bg = $Panel
onready var middle_container = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Middle
onready var right_container = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Right
onready var description = $Panel/MarginContainer/VBoxContainer/Description
onready var favorite_button = $Panel/FavoriteButton
onready var mastery_progress = $Panel/MasteryProgress
onready var mastery_label = $Panel/MasteryLabel
onready var grid = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Left/GridContainer
onready var title = $Panel/MarginContainer/VBoxContainer/Title
onready var left_column = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/LeftColumn
onready var right_column = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/RightColumn

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")
const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")
const RECIPE_BG = preload("res://assets/images/ui/book/recipe_page.png")
const RECIPE_MASTERED_BG = preload("res://assets/images/ui/book/mastered_recipe_page.png")
const MAX_REAGENT_COLUMN = 4
const HOVERED_SCALE = 1.05
const SCALE_SPEED = 5

var combination : Combination
var reagent_array := []
var mastery_unlocked := false
var tagged := true
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
		if right_container:
			right_container.queue_free()
		if middle_container:
			middle_container.queue_free()


func preview_mode(is_mastered: bool):
	mastery_label.hide()
	mastery_progress.hide()
	if is_mastered:
		description.text = RecipeManager.get_description(combination.recipe, true)
		bg.texture = RECIPE_MASTERED_BG
		title.text = title.text + "+"
		

func update_mastery(new_value: int, threshold: int):
	if new_value < threshold :
		mastery_label.text = "Mastery " + str(new_value) + "/" + str(threshold)
		mastery_progress.max_value = threshold
		mastery_progress.value = new_value
	else:
		mastery_label.text = "Mastered"
		favorite_button.visible = true
		mastery_progress.visible = false


func is_mastered():
	return mastery_unlocked


func unlock_mastery(show_message := true):
	if not mastery_unlocked:
		description.text = RecipeManager.get_description(combination.recipe, true)
		mastery_unlocked = true
		favorite_button.visible = true
		mastery_progress.visible = false
		mastery_label.text = "Mastered"
		bg.texture = RECIPE_MASTERED_BG
		title.text = title.text + "+"
		if show_message:
			MessageLayer.recipe_mastered(combination)


func set_favorite_button(status):
	if mastery_unlocked:
		favorite_button.pressed = status


func favorite_error():
	AudioManager.play_sfx("error")
	favorite_button.pressed = false


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


func _on_Button_pressed():
	emit_signal("pressed", combination, mastery_unlocked)


func _on_FavoriteButton_toggled(button_pressed):
	emit_signal("favorite_toggled", combination, button_pressed)


func _on_FavoriteButton_button_down():
	AudioManager.play_sfx("click")
