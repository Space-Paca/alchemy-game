extends Control

signal closed

onready var recipes = $CenterContainer/HBoxContainer.get_children()


func _ready():
	pass


func set_combinations(combinations: Array):
	assert(combinations.size() == recipes.size())
	for i in range(combinations.size()):
		recipes[i].set_combination(combinations[i])


func _on_Button_pressed():
	emit_signal("closed")
