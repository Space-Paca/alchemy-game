extends Control

signal hovered(reagent_array)
signal unhovered()
signal pressed(combination)

onready var description = $Panel/MarginContainer/Description
onready var grid = $Panel/MarginContainer/VBoxContainer/CenterContainer/GridContainer
onready var title = $Panel/MarginContainer/VBoxContainer/Title

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")

var combination : Combination
var reagent_array := []


func set_combination(_combination: Combination):
	combination = _combination
	title.text = combination.recipe.name
	description.text = combination.recipe.description
	grid.columns = combination.grid_size
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = REAGENT.instance()
			grid.add_child(reagent)
			reagent.set_reagent(combination.matrix[i][j])
			if combination.matrix[i][j]:
				reagent_array.append(combination.matrix[i][j])


func _on_Panel_mouse_entered():
	emit_signal("hovered", reagent_array)


func _on_Panel_mouse_exited():
	emit_signal("unhovered")


func _on_Button_pressed():
	emit_signal("pressed", combination)
