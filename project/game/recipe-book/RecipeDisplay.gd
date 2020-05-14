extends Control

signal hovered(reagent_array)
signal unhovered()
signal pressed(combination, mastery_unlocked)
signal favorite_toggled(combination, button_pressed)

onready var description = $Panel/MarginContainer/Description
onready var favorite_button = $Panel/FavoriteButton
onready var grid = $Panel/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/GridContainer
onready var title = $Panel/MarginContainer/VBoxContainer/Title
onready var reagent_list = $Panel/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/ReagentList

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")
const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")

var combination : Combination
var reagent_array := []
var mastery_unlocked := false


func set_combination(_combination: Combination):
	combination = _combination
	reagent_array = combination.recipe.reagents
	title.text = combination.recipe.name
	description.text = combination.recipe.description
	grid.columns = combination.grid_size
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = REAGENT.instance()
			grid.add_child(reagent)
			reagent.set_reagent(combination.known_matrix[i][j])
	
	if combination.discovered:
		reagent_list.queue_free()
	else:
		for reagent in combination.reagent_amounts:
			var reagent_amount = REAGENT_AMOUNT.instance()
			reagent_list.add_child(reagent_amount)
			reagent_amount.set_reagent(reagent)
			reagent_amount.set_amount(combination.reagent_amounts[reagent])


func update_combination():
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = grid.get_child(i*combination.grid_size + j)
			reagent.set_reagent(combination.known_matrix[i][j])
	
	if combination.discovered:
		reagent_list.queue_free()


func unlock_mastery():
	mastery_unlocked = true
	favorite_button.visible = true


func favorite_error():
	AudioManager.play_sfx("error")
	favorite_button.pressed = false


func _on_Panel_mouse_entered():
	if combination.discovered:
		emit_signal("hovered", reagent_array)


func _on_Panel_mouse_exited():
	if combination.discovered:
		emit_signal("unhovered")


func _on_Button_pressed():
	if combination.discovered:
		emit_signal("pressed", combination, mastery_unlocked)


func _on_FavoriteButton_toggled(button_pressed):
	emit_signal("favorite_toggled", combination, button_pressed)


func _on_FavoriteButton_button_down():
	AudioManager.play_sfx("click")
