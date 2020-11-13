extends Panel

signal hint_bought(combination)
signal bought(combination)

onready var grid = $CenterContainer/VBoxContainer/CenterContainer/RecipeGrid
onready var name_label = $CenterContainer/VBoxContainer/RecipeName
onready var description_label = $CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/DescriptionContainer/DescriptionLabel
onready var reagent_list = $CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/ReagentContainer/ReagentList
onready var buy_button = $CenterContainer/VBoxContainer/Buy
onready var hint_button = $CenterContainer/VBoxContainer/Hint

const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")
const HINT_COST_RATIO = .6

var combination : Combination
var player : Player
var buy_cost : int
var hint_cost : int
var current_buy_cost : int
var current_hint_cost : int


func set_combination(_combination: Combination):
	var size = _combination.grid_size
	combination = _combination
	
	# NAME
	name_label.text = combination.recipe.name
	
	# DESCRIPTION
	description_label.text = combination.recipe.description
	
	# BUTTONS
	buy_button.visible = false
	hint_button.visible = false
	hint_button.disabled = false
	
	# COST
	buy_cost = combination.recipe.shop_cost
	hint_cost = int(ceil(buy_cost * HINT_COST_RATIO))
	
	# GRID
	for i in grid.get_child_count():
		grid.get_child(i).visible = i < size * size
	grid.columns = combination.grid_size
	
	# REAGENTS
	for child in reagent_list.get_children():
		reagent_list.remove_child(child)
	
	for reagent in combination.reagent_amounts:
		var reagent_amount_display = REAGENT_AMOUNT.instance()
		reagent_list.add_child(reagent_amount_display)
		reagent_amount_display.set_reagent(reagent)
		reagent_amount_display.set_amount(combination.reagent_amounts[reagent])
	
	update_display()


func update_display():
	for i in combination.grid_size:
		for j in combination.grid_size:
			var display = grid.get_child(i* combination.grid_size + j)
			display.set_reagent(combination.known_matrix[i][j])
	
	current_buy_cost = buy_cost
	current_hint_cost = hint_cost
	for i in combination.hints:
		current_buy_cost /= 2
		current_hint_cost /= 2
	
	buy_button.text = "Buy Recipe (%d)" % buy_cost
	hint_button.text = "Buy Hint (%d)" % hint_cost
	
	if combination.discovered:
		buy_button.visible = false
		hint_button.visible = false
	elif combination.hints >= 2:
		hint_button.disabled = true
		hint_button.text = "Buy Hint"


func _on_Buy_pressed():
	if player.spend_gold(buy_cost):
		AudioManager.play_sfx("buy")
		combination.discover_all_reagents()
		update_display()
		emit_signal("bought", combination)
	else:
		AudioManager.play_sfx("error")


func _on_Hint_pressed():
	if player.spend_gold(hint_cost):
		combination.get_hint()
		update_display()
		AudioManager.play_sfx("discover_clue_recipe")
		emit_signal("hint_bought", combination)
	else:
		AudioManager.play_sfx("error")
