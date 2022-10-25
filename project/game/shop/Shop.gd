extends Control

signal closed
signal combinations_seen(combinations)
signal combination_bought(combination)
signal hint_bought(combination)

enum States {MENU, RECIPES, REAGENTS}

const DESTROY_BASE_COST := 20
const DESTROY_INCREMENTAL_COST := 10
const SHOP_RECIPE = preload("res://game/shop/ShopRecipe.tscn")
const SEASONAL_MOD = {
	"halloween": {
		"ui": Color("ff9126"),
		"dialogue": Color("dcb491d4"),
	}
}

onready var recipes = $RecipeMenu/HBoxContainer
onready var sold_amount = $RecipeMenu/HBoxContainer.get_children().size()
onready var reagent_list = $ReagentsMenu/ClickableReagentList
onready var reagent_destroy = $ReagentsMenu/ReagentDestroy
onready var reagent_destroy_panel = $ReagentsMenu/ReagentDestroy/Panel
onready var reagent_destroy_label = $ReagentsMenu/ReagentDestroy/ReagentDestroyLabel
onready var dialog_label = $ShopMenu/ShopkeeperDialogue/Panel/CenterContainer/DialogLabel
onready var panel = $ShopMenu/ShopkeeperDialogue/Panel
onready var dialogue_panel_point = $ShopMenu/ShopkeeperDialogue/Polygon2D
onready var destroy_panel_point = $ReagentsMenu/ReagentDestroy/Polygon2D
# MENUS
onready var shop_menu = $ShopMenu
onready var reagents_menu = $ReagentsMenu
onready var recipe_menu = $RecipeMenu
# BUTTONS
onready var recipe_button = $ShopMenu/RecipesButton
onready var reagents_button = $ShopMenu/ReagentsButton
onready var back_button = $BackButton
onready var destroy_yes_button = $ReagentsMenu/ReagentDestroy/ReagentDestroyLabel/HBoxContainer/YesButton
onready var destroy_no_button = $ReagentsMenu/ReagentDestroy/ReagentDestroyLabel/HBoxContainer/NoButton


var chosen_reagent_index : int
var player : Player
var dungeon_ref
var curr_state = States.MENU
var shown_combinations := []

func _ready():
	if Debug.seasonal_event:
		set_seasonal_look(Debug.seasonal_event)


func _process(dt):
	var lerp_speed = 6.5 if not dialog_label.is_complete() else 25.0
	panel.rect_size.y = lerp(panel.rect_size.y, 6 + dialog_label.get_content_height(), dt*lerp_speed)


func first_setup(combinations: Array, _player: Player, _dungeon):
	dungeon_ref = _dungeon
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
			recipe.disable_tooltips()
			shown_combinations.append(combinations[i])
		else:
			print("Shop.gd: Not enough combinations to fill shop")
			recipe.hide()


func get_save_data():
	var data = []
	for recipe in recipes.get_children():
		data.append(recipe.combination.recipe.name)
	return data


func load_combinations(combinations, _player, _dungeon):
	dungeon_ref = _dungeon
	player = _player
	update_reagents()
	
	for child in recipes.get_children():
		recipes.remove_child(child)
	
	for i in combinations.size():
		var recipe = SHOP_RECIPE.instance()
		recipes.add_child(recipe)
		recipe.connect("bought", self, "_on_ShopRecipe_bought")
		recipe.connect("hint_bought", self, "_on_ShopRecipe_hint_bought")
		recipe.set_combination(combinations[i])
		recipe.player = player
		recipe.disable_tooltips()

func setup():
	$AnimationPlayer.play("init")
	dialog_label.reset()
	panel.rect_size.y = 6
	update_combinations()
	update_reagents()


func set_seasonal_look(event_string):
	var path = "res://assets/images/background/shop/%s/" % event_string
	$Witch.texture = load(path + "witch.png")
	for child in $Witch.get_children():
		child.hide()
	$BG.texture = load(path + "bg.png")
	$TableGlass.texture = load(path + "table_glass.png")
	
	for node in [recipe_button, reagents_button, back_button,\
				 destroy_yes_button, destroy_no_button]:
		node.self_modulate = SEASONAL_MOD[event_string].ui
	dialogue_panel_point.color = SEASONAL_MOD[event_string].dialogue
	destroy_panel_point.color = SEASONAL_MOD[event_string].dialogue
	panel.get_stylebox("panel", "" ).bg_color = SEASONAL_MOD[event_string].dialogue


func start():
	$AnimationPlayer.play("enter")
	AudioManager.play_sfx("shop_entrance")


func paused():
	dialog_label.pause_dialog()


func exited_pause():
	dialog_label.resume_dialog()


func get_dialog():
	if not Profile.get_tutorial("first_shop"):
		Profile.set_tutorial("first_shop", true)
		return tr("SHOP_DIALOG_1")
	
	var dialogs = []
	for i in range(2, 5+1):
		dialogs.push_front("SHOP_DIALOG_"+str(i))
	#Having no/little money
	if player.gold <= 10:
		for _i in range(4): 
			dialogs.push_front("SHOP_DIALOG_6")
			dialogs.push_front("SHOP_DIALOG_7")
	#Having a lot of money
	if player.gold >= 500:
		for _i in range((player.pearls - 400)/100):
			dialogs.push_front("SHOP_DIALOG_8")
	#Woods Dialog
	if player.cur_level == 1:
		dialogs.push_front("SHOP_DIALOG_9")
	#Caverns Dialog
	if player.cur_level == 2:
		dialogs.push_front("SHOP_DIALOG_10")
	#Dungeon Dialog
	if player.cur_level == 3:
		dialogs.push_front("SHOP_DIALOG_11")

	dialogs.shuffle()
	return tr(dialogs.pop_front())


func start_dialog():
	dialog_label.start_dialog(get_dialog())


func complete_dialog():
	dialog_label.complete_dialog()
	yield(get_tree(), "idle_frame")
	panel.rect_size.y = 6 + dialog_label.get_content_height()


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


func get_destroy_cost():
	return DESTROY_BASE_COST + DESTROY_INCREMENTAL_COST*dungeon_ref.times_removed_reagent


func _on_BackButton_pressed():
	AudioManager.play_sfx("click")
	match curr_state:
		States.MENU:
			$AnimationPlayer.stop()
			dialog_label.reset()
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
	complete_dialog()
	yield(get_tree(), "idle_frame")
	shop_menu.hide()
	recipe_menu.show()
	for recipe in $RecipeMenu/HBoxContainer.get_children():
		recipe.enable_tooltips()
	emit_signal("combinations_seen", shown_combinations)


func _on_ReagentsButton_pressed():
	AudioManager.play_sfx("click")
	curr_state = States.REAGENTS
	complete_dialog()
	yield(get_tree(), "idle_frame")
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
	
	reagent_destroy.show()
	var reagent_name = tr(ReagentManager.get_data(reagent).name)
	if upgraded:
		reagent_name += "+"
	reagent_destroy_label.text = ""
	reagent_destroy_label.rect_size.x = 0 #Resizes so the label.size will be the exact size
	yield(get_tree(), "idle_frame")
	reagent_destroy_label.text = tr("DESTROY_REAGENT") % [reagent_name, get_destroy_cost()]
	yield(get_tree(), "idle_frame")
	var margin = reagent_destroy_label.rect_position.x
	reagent_destroy_panel.rect_size.x = 2*margin + reagent_destroy_label.rect_size.x


func _on_YesButton_pressed():
	if player.spend_gold(get_destroy_cost()):
		AudioManager.play_sfx("remove_reagent_from_bag")
		AudioManager.play_sfx("buy")
		player.destroy_reagent(chosen_reagent_index)
		dungeon_ref.times_removed_reagent += 1
		update_reagents()
		reagent_destroy.hide()
	else:
		AudioManager.play_sfx("error")


func _on_NoButton_pressed():
	AudioManager.play_sfx("click")
	reagent_destroy.hide()
	reagent_list.deactivate_reagents()


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_AdvanceDialogArea_pressed():
	dialog_label.speed_up_dialog()
