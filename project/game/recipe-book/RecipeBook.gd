extends Control

onready var grid = $ColorRect/VBoxContainer/ScrollContainer/GridContainer

const RECIPE = preload("res://game/recipe-book/RecipeDisplay.tscn")


func add_combination(combination: Combination, position: int):
	var recipe_display = RECIPE.instance()
	grid.add_child(recipe_display)
	grid.move_child(recipe_display, position)
	recipe_display.set_combination(combination)
