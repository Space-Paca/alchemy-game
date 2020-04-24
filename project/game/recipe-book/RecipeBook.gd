extends Control

signal recipe_pressed(combination)

onready var hand_grid : GridContainer = $ColorRect/MarginContainer/VBoxContainer/HandRect/CenterContainer/GridContainer
onready var hand_rect : ColorRect = $ColorRect/MarginContainer/VBoxContainer/HandRect
onready var recipe_grid : GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

const RECIPE = preload("res://game/recipe-book/RecipeDisplay.tscn")
const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")

var recipe_displays := {}


func add_combination(combination: Combination, position: int):
	var recipe_display = RECIPE.instance()
	recipe_grid.add_child(recipe_display)
	recipe_grid.move_child(recipe_display, position)
	recipe_display.set_combination(combination)
	recipe_display.connect("hovered", self, "_on_recipe_display_hovered")
	recipe_display.connect("unhovered", self, "_on_recipe_display_unhovered")
	recipe_display.connect("pressed", self, "_on_recipe_display_pressed")
	recipe_displays[combination.recipe.name] = recipe_display


func create_hand(battle):
	battle.connect("current_reagents_updated", self, "update_hand")
	hand_grid.columns = battle.hand.size / 2
	for _i in range(battle.hand.size):
		var reagent = REAGENT.instance()
		reagent.rect_min_size = Vector2(100, 100)
		hand_grid.add_child(reagent)
	hand_rect.visible = true


func remove_hand():
	for child in hand_grid.get_children():
		hand_grid.remove_child(child)
	
	hand_rect.visible = false


func toggle(_battle = null):
	visible = !visible
	
	if not visible:
		reset_hand_reagents_color()


func update_hand(reagents: Array):
	for i in reagents.size():
		hand_grid.get_child(i).set_reagent(reagents[i])


func color_hand_reagents(reagent_array: Array):
	if not hand_grid.get_child_count():
		return
	
	var reagents := reagent_array.duplicate()
	var correct_reagent_displays := []
	var i = 0
	while not reagents.empty() and i < hand_grid.get_child_count():
		var reagent = hand_grid.get_child(i).reagent_name
		for other in reagents:
			if reagent == other:
				correct_reagent_displays.append(hand_grid.get_child(i))
				reagents.erase(other)
				break
		i += 1
	
	if reagents.empty():
		for display in correct_reagent_displays:
			display.self_modulate = Color.green


func reset_hand_reagents_color():
	if not hand_grid.get_child_count():
		return
	
	for display in hand_grid.get_children():
		display.self_modulate = Color.white


func _on_recipe_display_hovered(reagent_array: Array):
	color_hand_reagents(reagent_array)


func _on_recipe_display_unhovered():
	reset_hand_reagents_color()


func _on_recipe_display_pressed(combination: Combination):
	var combination_reagents := []
	
	for line in combination.matrix:
		for reagent in line:
			if reagent:
				combination_reagents.append(reagent)
	
	var i = 0
	while not combination_reagents.empty() and i < hand_grid.get_child_count():
		var reagent = hand_grid.get_child(i).reagent_name
		for other in combination_reagents:
			if reagent == other:
				combination_reagents.erase(other)
				break
		i += 1
	
	if combination_reagents.empty():
		emit_signal("recipe_pressed", combination)
