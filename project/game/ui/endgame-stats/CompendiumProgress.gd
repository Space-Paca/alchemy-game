extends Control

onready var recipe_container = $ScrollContainer/RecipeContainer
onready var compendium_tooltip = $Table/Title/Info/TooltipCollision

const RECIPE = preload("res://game/ui/endgame-stats/RecipeMemorization.tscn")

var player : Player
var tooltip_enabled = false
var block_tooltips = false

func _ready():
	populate()
	disable_tooltips()

func set_player(p: Player):
	player = p


func update_known_recipe(recipe_id: String, amount_made: int) -> int:
	if Profile.known_recipes[recipe_id].amount == -1:
		Profile.known_recipes[recipe_id].amount = amount_made
	else:
		Profile.known_recipes[recipe_id].amount += amount_made
	
	return Profile.known_recipes[recipe_id].amount


func populate():
	for recipe_id in Profile.known_recipes.keys():
		var level = Profile.get_recipe_memorized_level(recipe_id)
		var recipe = Profile.known_recipes[recipe_id]
		
		var amount_made = player.made_recipes[recipe_id].amount
		if amount_made > 0 or amount_made > recipe.amount: 
			var recipe_obj = RECIPE.instance()
			recipe_container.add_child(recipe_obj)
			var new = recipe.amount == -1
			var total_amount = update_known_recipe(recipe_id, amount_made)
			var level_up = Profile.get_recipe_memorized_level(recipe_id) > level
			recipe_obj.set_recipe(recipe_id, amount_made, total_amount, new, level_up)
			recipe_obj.animate_progress()
	#Save new updates to recipes made
	FileManager.save_profile()


func get_compendium_hint_tooltip():
	var tip = {"title": tr("COMPENDIUM"), "text": tr("COMPENDIUM_INFO"),
			"title_image": "res://assets/images/ui/compendium_icon.png",
			"subtitle": ""}
	return tip


func enable_tooltips():
	block_tooltips = false


func disable_tooltips():
	block_tooltips = true
	remove_tooltips()


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	
	tooltip_enabled = true
	var tip = get_compendium_hint_tooltip()
	TooltipLayer.add_tooltip(compendium_tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()
