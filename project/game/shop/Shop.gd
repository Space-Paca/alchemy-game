extends Control

signal closed
signal combinations_seen(combinations)
signal combination_bought(combination)
signal hint_bought(combination)

onready var recipes = $RecipeMenu/HBoxContainer
onready var sold_amount = $RecipeMenu/HBoxContainer.get_children().size()
onready var reagent_list = $ReagentsMenu/ClickableReagentList
onready var reagent_destroy_label = $ReagentsMenu/ReagentDestroyLabel
# MENUS
onready var shop_menu = $ShopMenu
onready var reagents_menu = $ReagentsMenu
onready var recipe_menu = $RecipeMenu

enum States {MENU, RECIPES, REAGENTS}

const DESTROY_COST := 30
const DESTROY_TEXT := "Are you sure you want to destroy %s reagent for %d gold?"
const SHOP_RECIPE = preload("res://game/shop/ShopRecipe.tscn")

var chosen_reagent_index : int
var player : Player
var curr_state = States.MENU
var shown_combinations := []


func setup(combinations: Array, _player: Player):
	player = _player
	update_reagents()
	
	for child in recipes.get_children():
		recipes.remove_child(child)
	
	for i in 3:
		var recipe = SHOP_RECIPE.instance()
		recipes.add_child(recipe)
		if i < combinations.size() and combinations[i]:
			recipe.set_combination(combinations[i])
			recipe.player = player
			shown_combinations.append(combinations[i])
		else:
			print("Shop.gd: Not enough combinations to fill shop")
			recipe.hide()


func update_combinations():
	for recipe in recipes.get_children():
		recipe.update_display()


func update_reagents():
	var reagent_array = []
	reagent_list.clear()
	for reagent in player.bag:
		reagent_array.append(reagent.type)
	reagent_list.populate(reagent_array)


func _on_BackButton_pressed():
	match curr_state:
		States.MENU:
			emit_signal("closed")
		States.REAGENTS:
			curr_state = States.MENU
			reagents_menu.hide()
			shop_menu.show()
		States.RECIPES:
			curr_state = States.MENU
			recipe_menu.hide()
			shop_menu.show()


func _on_RecipesButton_pressed():
	curr_state = States.RECIPES
	shop_menu.hide()
	recipe_menu.show()
	emit_signal("combinations_seen", shown_combinations)


func _on_ReagentsButton_pressed():
	curr_state = States.REAGENTS
	shop_menu.hide()
	reagents_menu.show()


func _on_ShopRecipe_bought(combination: Combination):
	emit_signal("combination_bought", combination)


func _on_ShopRecipe_hint_bought(combination: Combination):
	emit_signal("hint_bought", combination)


func _on_ClickableReagentList_reagent_pressed(reagent_name, reagent_index):
	chosen_reagent_index = reagent_index
	
	reagent_destroy_label.show()
	reagent_destroy_label.text = DESTROY_TEXT % [reagent_name, DESTROY_COST]


func _on_YesButton_pressed():
	if player.spend_gold(DESTROY_COST):
		player.destroy_reagent(chosen_reagent_index)
		update_reagents()
		reagent_destroy_label.hide()
	else:
		AudioManager.play_sfx("error")


func _on_NoButton_pressed():
	reagent_destroy_label.hide()
