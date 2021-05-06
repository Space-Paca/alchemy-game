extends Control

onready var recipe_container = $ScrollContainer/RecipeContainer

const RECIPE = preload("res://game/ui/endgame-stats/RecipeMemorization.tscn")


func _ready():
	populate()


func populate():
	for recipe_name in Profile.known_recipes.keys():
		if Profile.known_recipes[recipe_name].made_in_run:
			var recipe = RECIPE.instance()
			recipe_container.add_child(recipe)
			recipe.set_recipe(recipe_name)
