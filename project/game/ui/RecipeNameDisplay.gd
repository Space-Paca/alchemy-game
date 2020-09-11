extends TextureRect

onready var label = $Label


func display_name_for_combination(combination):
	if combination:
		if combination is String and combination == "failure":
			label.text = "Miscombination"
		else:
			label.text = combination.recipe.name
	else:
		label.text = "???"


func reset():
	label.text = ""
