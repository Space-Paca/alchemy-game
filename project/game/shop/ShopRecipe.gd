extends Panel

signal hint_bought(combination)
signal bought(combination)

onready var grid = $CenterContainer/VBoxContainer/CenterContainer/RecipeGrid
onready var name_label = $CenterContainer/VBoxContainer/RecipeName
onready var reagent_list = $CenterContainer/VBoxContainer/MarginContainer/ReagentList
onready var buy_button = $CenterContainer/VBoxContainer/Buy
onready var hint_button = $CenterContainer/VBoxContainer/Hint

const REAGENT_AMOUNT = preload("res://game/shop/ReagentAmount.tscn")

var combination : Combination
var player : Player


func set_combination(_combination: Combination):
	var size = _combination.grid_size
	combination = _combination
	
	# NAME
	name_label.text = combination.recipe.name
	
	# GRID
	for i in range(size * size, grid.get_child_count()):
		grid.get_child(i).visible = false
	for i in range(size):
		for j in range(size):
			var display = grid.get_child(i*size + j)
			display.set_reagent(combination.known_matrix[i][j])
			display.visible = true
	grid.columns = combination.grid_size
	
	# REAGENTS
	var reagent_count = {}
	for reagent in combination.recipe.reagents:
		if reagent in reagent_count:
			reagent_count[reagent] += 1
		else:
			reagent_count[reagent] = 1
	for reagent in reagent_count:
		var reagent_amount_display = REAGENT_AMOUNT.instance()
		reagent_list.add_child(reagent_amount_display)
		reagent_amount_display.set_reagent(reagent)
		reagent_amount_display.set_amount(reagent_count[reagent])


func update_display():
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var display = grid.get_child(i* combination.grid_size + j)
			display.set_reagent(combination.known_matrix[i][j])
	
	if combination.discovered:
		buy_button.visible = false
		hint_button.visible = false
	else:
		hint_button.disabled = combination.unknown_reagent_coords.size() <= 1


func _on_Buy_pressed():
	combination.discover_all_reagents()
	update_display()
	
	emit_signal("bought", combination)


func _on_Hint_pressed():
# warning-ignore:integer_division
	var amount = combination.unknown_reagent_coords.size() / 2
	combination.discover_reagents(amount)
	update_display()
	
	emit_signal("hint_bought", combination)
