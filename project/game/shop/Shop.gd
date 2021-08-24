extends Control

signal closed
signal combinations_seen(combinations)
signal combination_bought(combination)
signal hint_bought(combination)

onready var recipes = $RecipeMenu/HBoxContainer
onready var sold_amount = $RecipeMenu/HBoxContainer.get_children().size()
onready var reagent_list = $ReagentsMenu/ClickableReagentList
onready var reagent_destroy_label = $ReagentsMenu/ReagentDestroyLabel
onready var dialog_label = $ShopMenu/ShopkeeperDialogue/Panel/CenterContainer/Label
onready var panel = $ShopMenu/ShopkeeperDialogue/Panel
# MENUS
onready var shop_menu = $ShopMenu
onready var reagents_menu = $ReagentsMenu
onready var recipe_menu = $RecipeMenu

enum States {MENU, RECIPES, REAGENTS}

const DESTROY_COST := 30
const DIALOG_SPEED := 25
const SHOP_RECIPE = preload("res://game/shop/ShopRecipe.tscn")

var chosen_reagent_index : int
var player : Player
var curr_state = States.MENU
var shown_combinations := []


func first_setup(combinations: Array, _player: Player):
	player = _player
	update_reagents()
	
	for child in recipes.get_children():
		recipes.remove_child(child)
	
	for i in 3:
		var recipe = SHOP_RECIPE.instance()
		recipes.add_child(recipe)
		recipe.connect("bought", self, "_on_ShopRecipe_bought")
		recipe.connect("hint_bought", self, "_on_ShopRecipe_hint_bought")
		if i < combinations.size() and combinations[i]:
			recipe.set_combination(combinations[i])
			recipe.player = player
			shown_combinations.append(combinations[i])
		else:
			print("Shop.gd: Not enough combinations to fill shop")
			recipe.hide()

func setup():
	update_combinations()
	update_reagents()
	dialog_label.percent_visible = 0
	panel.rect_size.y = 60

func start():
	dialog_label.text = tr("SHOP_DIALOG_1")
	dialog_label.bbcode_text = tr("SHOP_DIALOG_1")
	yield(get_tree(), "idle_frame") #necessary just while we dont have animation
	start_dialogue()
	#$AnimationPlayer.play("enter")


func start_dialogue():
	var dur = dialog_label.get_total_character_count()/DIALOG_SPEED
	$Tween.interpolate_property(dialog_label, "percent_visible", 0, 1, dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(panel, "rect_size:y", panel.rect_size.y, 340, dur*.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func update_combinations():
	for recipe in recipes.get_children():
		recipe.update_display()


func update_reagents():
	var reagent_array = []
	reagent_list.clear()
	reagent_list.deactivate_reagents()
	for reagent in player.bag:
		reagent_array.append({"type":reagent.type, "upgraded": reagent.upgraded})
	reagent_list.populate(reagent_array)


func _on_BackButton_pressed():
	match curr_state:
		States.MENU:
			emit_signal("closed")
		States.REAGENTS:
			curr_state = States.MENU
			reagents_menu.hide()
			reagent_list.disable_tooltips()
			reagent_list.deactivate_reagents()
			shop_menu.show()
		States.RECIPES:
			curr_state = States.MENU
			recipe_menu.hide()
			for recipe in $RecipeMenu/HBoxContainer.get_children():
				recipe.disable_tooltips()
			shop_menu.show()


func _on_RecipesButton_pressed():
	curr_state = States.RECIPES
	shop_menu.hide()
	recipe_menu.show()
	for recipe in $RecipeMenu/HBoxContainer.get_children():
		recipe.enable_tooltips()
	emit_signal("combinations_seen", shown_combinations)


func _on_ReagentsButton_pressed():
	curr_state = States.REAGENTS
	shop_menu.hide()
	reagents_menu.show()
	reagent_list.enable_tooltips()


func _on_ShopRecipe_bought(combination: Combination):
	emit_signal("combination_bought", combination)


func _on_ShopRecipe_hint_bought(combination: Combination):
	emit_signal("hint_bought", combination)


func _on_ClickableReagentList_reagent_pressed(reagent, reagent_index, upgraded):
	reagent_list.activate_reagent(reagent_index)
	chosen_reagent_index = reagent_index
	
	reagent_destroy_label.show()
	var reagent_name = tr(ReagentManager.get_data(reagent).name)
	if upgraded:
		reagent_name += "+"
	reagent_destroy_label.text = tr("DESTROY_REAGENT") % [reagent_name, DESTROY_COST]


func _on_YesButton_pressed():
	if player.spend_gold(DESTROY_COST):
		player.destroy_reagent(chosen_reagent_index)
		update_reagents()
		reagent_destroy_label.hide()
	else:
		AudioManager.play_sfx("error")


func _on_NoButton_pressed():
	reagent_destroy_label.hide()
	reagent_list.deactivate_reagents()
