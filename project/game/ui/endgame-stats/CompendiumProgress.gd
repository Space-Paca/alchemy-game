extends Control

onready var recipe_container = $ScrollContainer/RecipeContainer
onready var compendium_tooltip = $Table/Title/Info/TooltipCollision

const RECIPE = preload("res://game/ui/endgame-stats/RecipeMemorization.tscn")

var player : Player
var tooltip_enabled = false

func _ready():
#	for child in recipe_container.get_children():
#		recipe_container.remove_child(child)
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


func get_compendium_hint_tooltip():
	var tip = {"title": "Compendium", "text": "The Compendium stores all recipes you've made, and how many times you've created them. If you do them enough times, they'll be Memorized, making them easier to create in future adventures", \
				   "title_image": "res://assets/images/ui/compendium_icon.png", "subtitle": ""}

	return tip


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func _on_TooltipCollision_enable_tooltip():
	tooltip_enabled = true
	var tip = get_compendium_hint_tooltip()
	TooltipLayer.add_tooltip(compendium_tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()
