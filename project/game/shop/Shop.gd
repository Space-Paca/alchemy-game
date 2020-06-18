extends Control

signal closed
signal combination_bought(combination)
signal hint_bought(combination)

onready var recipes = $RecipeMenu/HBoxContainer.get_children()
onready var sold_amount = $RecipeMenu/HBoxContainer.get_children().size()
onready var currency_label = $CurrencyLabel
onready var reagent_list = $ReagentsMenu/ClickableReagentList
onready var reagent_destroy_label = $ReagentsMenu/ReagentDestroyLabel
# MENUS
onready var shop_menu = $ShopMenu
onready var reagents_menu = $ReagentsMenu
onready var recipe_menu = $RecipeMenu

enum States {MENU, RECIPES, REAGENTS}

const DESTROY_REAGENT_COST := 30

var player : Player
var curr_state = States.MENU


func setup(combinations: Array, _player: Player):
	player = _player
	update_reagents()
	
	for i in range(recipes.size()):
		if i < combinations.size() and combinations[i]:
			recipes[i].set_combination(combinations[i])
			recipes[i].player = player
		else:
			print("Shop.gd: Not enough combinations to fill shop")
			recipes[i].hide()


func update_combinations():
	for recipe in recipes:
		recipe.update_display()


func update_reagents():
	var reagent_array = []
	reagent_list.reset()
	for reagent in player.bag:
		reagent_array.append(reagent.type)
	reagent_list.populate(reagent_array)


func update_currency():
	currency_label.text = "Player Gold: %d" % player.currency


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


func _on_ReagentsButton_pressed():
	curr_state = States.REAGENTS
	shop_menu.hide()
	reagents_menu.show()


func _on_ShopRecipe_bought(combination: Combination):
	update_currency()
	emit_signal("combination_bought", combination)


func _on_ShopRecipe_hint_bought(combination: Combination):
	update_currency()
	emit_signal("hint_bought", combination)


func _on_ClickableReagentList_reagent_pressed(reagent_name):
	pass # Replace with function body.


func _on_YesButton_pressed():
	pass # Replace with function body.


func _on_NoButton_pressed():
	pass # Replace with function body.
