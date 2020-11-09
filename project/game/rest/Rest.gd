extends Control

signal closed
signal combination_rewarded

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")
const REST_HEAL_PERCENTAGE = 35
const GREAT_REST_HEAL_PERCENTAGE = 70

var map_node : MapNode
var player
var combinations


func setup(node, _player, _combinations):
	map_node = node
	player = _player
	combinations = _combinations
	
	update_heal_button()
	
	$BackButton.show()
	$HealButton.show()
	$HintButton.show()
	$Recipes.hide()
	$ContinueButton.hide()

func get_percent_heal():
	if player.has_artifact("full_rest"):
		return 100
	elif player.has_artifact("great_rest"):
		return GREAT_REST_HEAL_PERCENTAGE
	else:
		return REST_HEAL_PERCENTAGE


func get_heal_value():
	if player.has_artifact("full_rest"):
		return player.max_hp
	elif player.has_artifact("great_rest"):
		return GREAT_REST_HEAL_PERCENTAGE/100.0 * player.max_hp
	else:
		return REST_HEAL_PERCENTAGE/100.0 * player.max_hp


func update_heal_button():
	$HealButton.text = "heal " + str(get_heal_value()) + " hp ("+get_percent_heal()+"%)" 


func reset_room():
	map_node.set_type(MapNode.EMPTY)


func setup_recipes():
	for child in $Recipes/HBox.get_children():
		$Recipes/HBox.remove_child(child)
	
	for combination in combinations:
		create_display(combination)


func create_display(combination):
	var recipe_display = RECIPE.instance()
	recipe_display.discover_all = true
	$Recipes/HBox.add_child(recipe_display)
	recipe_display.set_combination(combination)
	recipe_display.connect("chosen", self, "_on_recipe_chosen")


func _on_HealButton_pressed():
	AudioManager.play_sfx("heal")
	player.hp = min(player.hp + get_heal_value(), player.max_hp)
	reset_room()
	emit_signal("closed")


func _on_HintButton_pressed():
	if combinations.size() > 0:
		$BackButton.hide()
		$HealButton.hide()
		$HintButton.hide()
		$Recipes.show()
		setup_recipes()
	else:
		AudioManager.play_sfx("error")


func _on_ContinueButton_pressed():
	reset_room()
	emit_signal("closed")


func _on_BackButton_pressed():
	emit_signal("closed")


func _on_recipe_chosen(chosen_recipe):
	for recipe_display in $Recipes/HBox.get_children():
		if recipe_display != chosen_recipe:
			$Recipes/HBox.remove_child(recipe_display)

	emit_signal("combination_rewarded", chosen_recipe.combination)
	$ContinueButton.show()
