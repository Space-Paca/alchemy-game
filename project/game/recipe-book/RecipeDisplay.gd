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
onready var mastery_label = $Panel/MasteryLabelContainer
onready var grid = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Left/GridContainer
onready var title = $Panel/MarginContainer/VBoxContainer/TitleContainer/Title
onready var left_column = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/LeftColumn
onready var right_column = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Right/ReagentList/RightColumn
onready var icon = $Panel/Icon

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")
const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")
const RECIPE_MASTERED_BG = preload("res://assets/images/ui/book/mastered_recipe_page.png")
const MAX_REAGENT_COLUMN = 4
const HOVERED_SCALE = 1.05
const SCALE_SPEED = 5
const ALPHA_SPEED = 4
const MAX_TITLE_FONT_SIZE = 38

var combination : Combination
var reagent_array := []
var mastery_unlocked := false
var memorized := false
var tagged := true
var filtered := true
var hovered := false
var mouse_over_favorite := false
var ignore_signal = false


func _ready():
	favorite_button.get_node("Label").modulate.a = 0.0
	favorite_button.hide()


func _process(delta):
	if hovered:
		rect_scale.x = min(rect_scale.x + delta*SCALE_SPEED, HOVERED_SCALE)
		rect_scale.y = min(rect_scale.y + delta*SCALE_SPEED, HOVERED_SCALE)
	else:
		rect_scale.x = max(rect_scale.x - delta*SCALE_SPEED, 1)
		rect_scale.y = max(rect_scale.y - delta*SCALE_SPEED, 1)
	
	var fav_label = favorite_button.get_node("Label")
	if mouse_over_favorite:
		fav_label.modulate.a = min(fav_label.modulate.a + delta*ALPHA_SPEED, 1.0)
	else:
		fav_label.modulate.a = max(fav_label.modulate.a - delta*ALPHA_SPEED, 0.0)


func update_title_size():
	var font = title.get("custom_fonts/font")
	font.set("size", MAX_TITLE_FONT_SIZE)
	var font_size = MAX_TITLE_FONT_SIZE
	while title.get_visible_line_count() < title.get_line_count():
		font_size = font_size-1
		font.set("size", font_size)


func set_combination(_combination: Combination):
	combination = _combination
	reagent_array = combination.recipe.reagents
	icon.texture = combination.recipe.fav_icon
	title.text = combination.recipe.name
	update_title_size()
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
	
	if Profile.is_recipe_memorized(combination.recipe.id):
		memorized = true
		favorite_button.visible = true


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


func preview_mode(is_mastered: bool):
	mastery_label.hide()
	mastery_progress.hide()
	favorite_button.hide()
	if is_mastered:
		description.text = RecipeManager.get_description(combination.recipe, true)
		bg.texture = RECIPE_MASTERED_BG
		title.text = tr(title.text) + "+"
		update_title_size()


func update_mastery(new_value: int, threshold: int):
	if new_value < threshold :
		mastery_label.get_node("Mastery").text = "MASTERY"
		mastery_label.get_node("Amount").text = str(new_value) + "/" + str(threshold)
		mastery_progress.max_value = threshold
		mastery_progress.value = new_value
	else:
		mastery_label.get_node("Mastery").text = "MASTERED"
		mastery_label.get_node("Amount").text = ""
		favorite_button.visible = true
		mastery_progress.visible = false


func is_mastered():
	return mastery_unlocked


func unlock_mastery(show_message: bool, favorited: bool) -> bool:
	if mastery_unlocked:
		return false
	
	description.text = RecipeManager.get_description(combination.recipe, true)
	mastery_unlocked = true
	mastery_progress.visible = false
	mastery_label.get_node("Mastery").text = "MASTERED"
	mastery_label.get_node("Amount").text = ""
	bg.texture = RECIPE_MASTERED_BG
	title.text = tr(title.text) + "+"
	update_title_size()
	if show_message:
		MessageLayer.recipe_mastered(combination, favorited)
	
	return true


func set_favorite_button(status, temp_disconnect = false):
	if mastery_unlocked or memorized:
		if temp_disconnect:
			ignore_signal = true
		favorite_button.pressed = status


func favorite_error():
	AudioManager.play_sfx("error")
	favorite_button.pressed = false


func enable_tooltips():
	for reagent_amount in grid.get_children():
		reagent_amount.enable_tooltips()
	
	if left_column and is_instance_valid(left_column):
		for reagent_amount in left_column.get_children():
			reagent_amount.enable_tooltips()
	if right_column and is_instance_valid(right_column):
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
	if not ignore_signal:
		emit_signal("favorite_toggled", combination, button_pressed)
	else:
		ignore_signal = false


func _on_FavoriteButton_button_down():
	AudioManager.play_sfx("click")


func _on_FavoriteButton_mouse_entered():
	mouse_over_favorite = true


func _on_FavoriteButton_mouse_exited():
	mouse_over_favorite = false
