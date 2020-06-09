extends Control

signal closed
signal combination_rewarded

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")
const REST_HEAL = 70

var room
var player
var combinations

func setup(_room, _player, _combinations):
	room = _room
	player = _player
	combinations = _combinations
	
	$BackButton.show()
	$HealButton.show()
	$HintButton.show()
	$Recipes.hide()
	$ContinueButton.hide()

func reset_room():
	room.reset()

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
	player.hp = min(player.hp + REST_HEAL, player.max_hp)
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


