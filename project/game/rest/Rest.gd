extends Control

signal closed
signal combination_studied

const RECIPE = preload("res://game/rest/RestRecipe.tscn")
const REST_HEAL_PERCENTAGE = 35
const GREAT_REST_HEAL_PERCENTAGE = 70

onready var warning = $Warning
onready var warning_label = $Warning/Label

var map_node : MapNode
var player
var combinations
var state = "main"
var disable_heal_button = false

func setup(node, _player, _combinations):
	state = "main"
	map_node = node
	player = _player
	combinations = _combinations
	
	update_heal_button()
	
	$Warning.modulate.a = 0
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
	var button = $HealButton
	if player.has_artifact("cursed_scholar_mask"):
		button.text = "CAN'T HEAL"
		button.modulate.r = .7; button.modulate.g = .7; button.modulate.b = .7
		disable_heal_button = "Can't heal while wearing the Cursed Scholar's Mask"
	else:
		disable_heal_button = false
		button.modulate.r = 1.0; button.modulate.g = 1.0; button.modulate.b = 1.0
		button.text = "HEAL " + str(get_heal_value()) + " HP ("+str(get_percent_heal())+"% max hp)" 


func reset_room():
	if map_node:
		map_node.set_type(MapNode.EMPTY)


func setup_recipes():
	for child in $Recipes/HBox.get_children():
		$Recipes/HBox.remove_child(child)
	
	for combination in combinations:
		create_display(combination)


func create_display(combination):
	var recipe_display = RECIPE.instance()
	$Recipes/HBox.add_child(recipe_display)
	recipe_display.set_combination(combination)
	recipe_display.enable_tooltips()
	recipe_display.connect("chosen", self, "_on_recipe_chosen")


func _on_HealButton_pressed():
	if disable_heal_button:
		AudioManager.play_sfx("error")
		warning_label.text = disable_heal_button
		var tween = $Warning/WarningTween
		var cur_a = warning.modulate.a
		tween.stop_all()
		tween.interpolate_property(warning, "modulate:a", cur_a, 1, (1-cur_a)*.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(warning, "modulate:a", 1, 0, .3, Tween.TRANS_CUBIC, Tween.EASE_IN, 1.6)
		tween.start()
	else:
		AudioManager.play_sfx("heal")
		player.hp = min(player.hp + get_heal_value(), player.max_hp)
		reset_room()
		emit_signal("closed")


func _on_HintButton_pressed():
	if combinations.size() > 0:
		$ChooseOneLabel.hide()
		$HealButton.hide()
		$HintButton.hide()
		$Recipes.show()
		setup_recipes()
		state = "recipes"
	else:
		AudioManager.play_sfx("error")


func _on_ContinueButton_pressed():
	reset_room()
	emit_signal("closed")


func _on_BackButton_pressed():
	if state == "recipes":
		$ChooseOneLabel.show()
		$HealButton.show()
		$HintButton.show()
		$Recipes.hide()
		for child in $Recipes/HBox.get_children():
			$Recipes/HBox.remove_child(child)
		state = "main"
	else:
		emit_signal("closed")


func _on_recipe_chosen(chosen_recipe):
	for recipe_display in $Recipes/HBox.get_children():
		if recipe_display != chosen_recipe:
			$Recipes/HBox.remove_child(recipe_display)

	emit_signal("combination_studied", chosen_recipe.combination)
	$ContinueButton.show()
