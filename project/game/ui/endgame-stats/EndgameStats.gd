extends Control

onready var recipe_container = $ScrollContainer/RecipeContainer

const RECIPE = preload("res://game/ui/endgame-stats/RecipeMemorization.tscn")

var player : Player


func _ready():
	populate()


func set_player(p: Player):
	player = p


func update_known_recipe(recipe_name: String, amount_made: int) -> int:
	if Profile.known_recipes[recipe_name].amount == -1:
		Profile.known_recipes[recipe_name].amount = amount_made
	else:
		Profile.known_recipes[recipe_name].amount += amount_made
		if Profile.known_recipes[recipe_name].amount >\
				Profile.known_recipes[recipe_name].memorized_threshold:
			Profile.memorize_recipe(recipe_name)
	
	return Profile.known_recipes[recipe_name].amount


func populate():
	for recipe_name in Profile.known_recipes.keys():
		if Profile.known_recipes[recipe_name].memorized:
			continue
		
		var amount_made = player.made_recipes[recipe_name].amount
		if amount_made >= 0 or amount_made > Profile.known_recipes[recipe_name].amount:
			var new = Profile.known_recipes[recipe_name].amount == -1
			var total_amount = update_known_recipe(recipe_name, amount_made)
			var recipe = RECIPE.instance()
			recipe_container.add_child(recipe)
			recipe.set_recipe(recipe_name, amount_made, total_amount, new)
