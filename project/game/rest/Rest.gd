extends Control

signal closed
signal combination_studied

const RECIPE = preload("res://game/rest/RestRecipe.tscn")
const REST_HEAL_PERCENTAGE = 35
const GREAT_REST_HEAL_PERCENTAGE = 70
const FULL_REST_HEAL_PERCENTAGE = 100

onready var warning = $Warning
onready var warning_label = $Warning/Label
onready var heal_button_label = $ButtonContainer/HealButton/Text

var map_node : MapNode
var player
var combinations
var state = "main"
var disable_heal_text = false

func setup(node, _player, _combinations):
	state = "main"
	map_node = node
	player = _player
	combinations = _combinations
	
	update_heal_button()
	
	$Warning.modulate.a = 0
	$BackButton.show()
	$ButtonContainer/HealButton.show()
	$ButtonContainer/HintButton.show()
	$Panel.hide()
	$ContinueButton.hide()


func get_percent_heal_color():
	if player.has_artifact("full_rest"):
		return "fuchsia"
	elif player.has_artifact("great_rest"):
		return "green"
	else:
		return "black"


func get_percent_heal():
	if player.has_artifact("full_rest"):
		return FULL_REST_HEAL_PERCENTAGE
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
	var button = $ButtonContainer/HealButton
	if player.has_artifact("cursed_scholar_mask"):
		heal_button_label.bbcode_text = "[center][color=#870900]"+tr("CANT_HEAL")+"[/color][/center]"
		disable_heal_text = "CANT_HEAL_SCHOLAR_MASK"
	else:
		disable_heal_text = false
		button.modulate.r = 1.0; button.modulate.g = 1.0; button.modulate.b = 1.0
		heal_button_label.bbcode_text = tr("HEAL_TEXT") % \
				[get_heal_value(), get_percent_heal_color(), get_percent_heal()] 


func reset_room():
	if map_node:
		map_node.set_type(MapNode.EMPTY)


func setup_recipes():
	for child in $Panel/Recipes/HBox.get_children():
		$Panel/Recipes/HBox.remove_child(child)
	
	for combination in combinations:
		create_display(combination)


func create_display(combination):
	var recipe_display = RECIPE.instance()
	$Panel/Recipes/HBox.add_child(recipe_display)
	recipe_display.set_combination(combination)
	recipe_display.enable_tooltips()
	recipe_display.connect("chosen", self, "_on_recipe_chosen")


func _on_HealButton_pressed():
	if disable_heal_text:
		AudioManager.play_sfx("error")
		warning_label.text = tr(disable_heal_text)
		var tween = $Warning/WarningTween
		var cur_a = warning.modulate.a
		tween.stop_all()
		tween.interpolate_property(warning, "modulate:a", cur_a, 1, (1-cur_a)*.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(warning, "modulate:a", 1, 0, .3, Tween.TRANS_CUBIC, Tween.EASE_IN, 4.6)
		tween.start()
	else:
		AudioManager.play_sfx("heal")
		player.hp = min(player.hp + get_heal_value(), player.max_hp)
		reset_room()
		emit_signal("closed")


func _on_HintButton_pressed():
	if combinations.size() > 0:
		$ChooseOneLabel.hide()
		$ButtonContainer/HealButton.hide()
		$ButtonContainer/HintButton.hide()
		$Panel.show()
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
		$ButtonContainer/HealButton.show()
		$ButtonContainer/HintButton.show()
		$Panel.hide()
		for child in $Panel/Recipes/HBox.get_children():
			$Panel/Recipes/HBox.remove_child(child)
		state = "main"
	else:
		emit_signal("closed")


func _on_recipe_chosen(chosen_recipe):
	for recipe_display in $Panel/Recipes/HBox.get_children():
		if recipe_display != chosen_recipe:
			$Panel/Recipes/HBox.remove_child(recipe_display)

	emit_signal("combination_studied", chosen_recipe.combination)
	$ContinueButton.show()
	$BackButton.hide()


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")
