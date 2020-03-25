extends Node

var combinations := []


func _ready():
	randomize()
	create_combinations()


func create_combinations():
	for recipe in RecipeManager.recipes.values():
		var combination = Combination.new()
		combination.create_from_recipe(recipe)
		combinations.append(combination)
