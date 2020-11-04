extends Control

onready var label = $Label

const RED = Color(1,0.1,0.1,1)
const BLACK = Color(0,0,0,1)
const NORMAL_FONT = preload("res://game/ui/RecipeNameNormalFont.tres")
const OUTLINE_FONT = preload("res://game/ui/RecipeNameOutlineFont.tres")


func display_name_for_combination(combination):
	if combination:
		if combination is String and combination == "failure":
			label.text = "Miscombination"
			set_label_color(RED, OUTLINE_FONT)
		else:
			label.text = combination.recipe.name
			set_label_color(BLACK, NORMAL_FONT)
	else:
		label.text = "???"
		set_label_color(BLACK, NORMAL_FONT)


func set_label_color(c, font):
	$Label.add_color_override("font_color", c)
	$Label.add_font_override("font", font)

func get_name():
	return label.text

func reset():
	label.text = ""
