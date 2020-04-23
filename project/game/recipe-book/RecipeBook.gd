extends Control

onready var hand_grid : GridContainer = $ColorRect/MarginContainer/VBoxContainer/HandRect/CenterContainer/GridContainer
onready var hand_rect : ColorRect = $ColorRect/MarginContainer/VBoxContainer/HandRect
onready var recipe_grid : GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

const RECIPE = preload("res://game/recipe-book/RecipeDisplay.tscn")
const REAGENT = preload("res://game/recipe-book/ReagentDisplay.tscn")


func add_combination(combination: Combination, position: int):
	var recipe_display = RECIPE.instance()
	recipe_grid.add_child(recipe_display)
	recipe_grid.move_child(recipe_display, position)
	recipe_display.set_combination(combination)


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


func toggle(battle = null):
	visible = !visible


func update_hand(reagents: Array):
	for i in reagents.size():
		hand_grid.get_child(i).set_reagent(reagents[i])
