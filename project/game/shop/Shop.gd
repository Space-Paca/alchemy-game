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
const DIALOG_SPEED_MOD := [1.0, 10.0]
const ALTERNATIVE_SPEED_MOD := {
	"fast": .35,
	"slow": 3.5,
}
const WAIT_TIME := 0.3
const SHORT_WAIT_TIME := 0.15
const LONG_WAIT_TIME := 1.0
const SHOP_RECIPE = preload("res://game/shop/ShopRecipe.tscn")

var chosen_reagent_index : int
var player : Player
var curr_state = States.MENU
var shown_combinations := []
var dialog_to_use = ""
var current_dialog_speed = 0
var alternative_speed_mod = 1.0


func _process(dt):
	panel.rect_size.y = lerp(panel.rect_size.y, 6 + dialog_label.get_content_height(), dt*8)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and dialog_to_use.length() > 0:
			current_dialog_speed = min(current_dialog_speed+1, DIALOG_SPEED_MOD.size())


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
	dialog_to_use = ""
	current_dialog_speed = 0
	alternative_speed_mod = 1.0
	dialog_label.bbcode_text = ""
	panel.rect_size.y = 6
	update_combinations()
	update_reagents()

func start():
	dialog_label.bbcode_text = ""
	yield(get_tree(), "idle_frame") #necessary just while we dont have animation
	dialog_to_use = tr("SHOP_DIALOG_1")
	advance_dialogue()
	#$AnimationPlayer.play("enter")


func advance_dialogue():
	if dialog_to_use[0] == '[':
		if dialog_to_use[1] == '/':
			if dialog_to_use.begins_with("[/slow]") or dialog_to_use.begins_with("[/fast]"):
				alternative_speed_mod = 1.0
			else:
				dialog_label.pop()
				
			while dialog_to_use[0] != ']':
				dialog_to_use = dialog_to_use.substr(1, -1)
			dialog_to_use = dialog_to_use.substr(1, -1)
		else:
			var found = false
			for effect in ["[shake]", "[wave]", "[i]",\
						   "[wait]", "[shortwait]", "[longwait]",\
						   "[slow]", "[fast]"]:
				if dialog_to_use.begins_with(effect):
					found = true
					if effect == "[wait]":
						yield(get_tree().create_timer(WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[shortwait]":
						yield(get_tree().create_timer(SHORT_WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[longwait]":
						yield(get_tree().create_timer(LONG_WAIT_TIME/DIALOG_SPEED_MOD[current_dialog_speed]), "timeout")
					elif effect == "[slow]":
						alternative_speed_mod = ALTERNATIVE_SPEED_MOD.slow
					elif effect == "[fast]":
						alternative_speed_mod = ALTERNATIVE_SPEED_MOD.fast
					else:
						dialog_label.append_bbcode(effect)
					dialog_to_use = dialog_to_use.trim_prefix(effect)
					break
			if not found:
				push_error("Not a valid effect: " + dialog_to_use)
				while dialog_to_use[0] != ']':
					dialog_to_use = dialog_to_use.substr(1, -1)
				dialog_to_use = dialog_to_use.substr(1, -1)
	else:
		dialog_label.append_bbcode(dialog_to_use[0])
		dialog_to_use = dialog_to_use.substr(1, -1)
	
	if dialog_to_use.length() > 0:
		yield(get_tree().create_timer(alternative_speed_mod/(DIALOG_SPEED*DIALOG_SPEED_MOD[current_dialog_speed])), "timeout")
		advance_dialogue()


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
	AudioManager.play_sfx("click")
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
	AudioManager.play_sfx("click")
	curr_state = States.RECIPES
	shop_menu.hide()
	recipe_menu.show()
	for recipe in $RecipeMenu/HBoxContainer.get_children():
		recipe.enable_tooltips()
	emit_signal("combinations_seen", shown_combinations)


func _on_ReagentsButton_pressed():
	AudioManager.play_sfx("click")
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
		AudioManager.play_sfx("click")
		player.destroy_reagent(chosen_reagent_index)
		update_reagents()
		reagent_destroy_label.hide()
	else:
		AudioManager.play_sfx("error")


func _on_NoButton_pressed():
	AudioManager.play_sfx("click")
	reagent_destroy_label.hide()
	reagent_list.deactivate_reagents()


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")

