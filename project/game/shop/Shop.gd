extends Control

signal closed
signal combination_bought(combination)
signal hint_bought(combination)

onready var recipes = $CenterContainer/HBoxContainer.get_children()
onready var sold_amount = $CenterContainer/HBoxContainer.get_children().size()

var player : Player


func set_combinations(combinations: Array):
	assert(combinations.size() == recipes.size())
	for i in range(combinations.size()):
		recipes[i].set_combination(combinations[i])
		recipes[i].player = player


func update_combinations():
	for recipe in recipes:
		recipe.update_display()


func _on_BackButton_pressed():
	emit_signal("closed")


func _on_ShopRecipe_bought(combination: Combination):
	emit_signal("combination_bought", combination)


func _on_ShopRecipe_hint_bought(combination: Combination):
	emit_signal("hint_bought", combination)
