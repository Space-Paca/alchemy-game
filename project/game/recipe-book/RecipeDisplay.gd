extends Control

onready var description = $Panel/MarginContainer/Description
onready var grid = $Panel/MarginContainer/VBoxContainer/CenterContainer/GridContainer
onready var title = $Panel/MarginContainer/VBoxContainer/Title

const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")


func set_combination(combination: Combination):
	title.text = combination.recipe.name
	description.text = combination.recipe.description
	grid.columns = combination.grid_size
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var reagent = REAGENT.instance()
			grid.add_child(reagent)
			reagent.set_reagent(combination.matrix[i][j])
