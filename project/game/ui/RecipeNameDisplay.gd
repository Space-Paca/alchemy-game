extends Control

const RED = Color(1,0.3,0.3,1)
const NORMAL_FONT = preload("res://game/ui/RecipeNameNormalFont.tres")
const OUTLINE_FONT = preload("res://game/ui/RecipeNameOutlineFont.tres")
const SEASONAL_MOD = {
	"halloween": {
		"ui": Color("ff9126"),
		"regular_font": Color("000000"),
	},
	"eoy_holidays": {
		"ui": Color("00d3f6"),
		"regular_font": Color("c1feff"),
	},
}

export var hide_description := false
export var use_seasonal_tint := false

onready var recipe_name_bg = $RecipeNameBG
onready var recipe_name_label = $RecipeName
onready var recipe_description_label = $RecipeDescription

var regular_color = Color(0,0,0,1)

func _ready():
	reset()
	if hide_description:
		recipe_description_label.hide()
		$RecipeDescriptionBG.hide()
	if use_seasonal_tint and Debug.seasonal_event:
		set_seasonal_look(Debug.seasonal_event)


func set_seasonal_look(event_string):
	recipe_name_bg.self_modulate = SEASONAL_MOD[event_string].ui
	regular_color = SEASONAL_MOD[event_string].regular_font


func display_name_for_combination(combination, update_description : bool, mastered := false):
	if combination:
		if combination is String and combination == "failure":
			recipe_name_label.text = "MISCOMBINATION"
			recipe_description_label.text = ""
			set_label_color(RED, OUTLINE_FONT)
		else:
			recipe_name_label.text = tr(combination.recipe.name)
			if mastered:
				recipe_name_label.text += "+"
			if update_description:
				recipe_description_label.text = RecipeManager.get_short_description(combination.recipe, mastered)
			else:
				recipe_description_label.text = ""
			set_label_color(regular_color, NORMAL_FONT)
	else:
		recipe_name_label.text = "???"
		recipe_description_label.text = ""
		set_label_color(regular_color, NORMAL_FONT)


func set_label_color(c, font):
	recipe_name_label.add_color_override("font_color", c)
	recipe_name_label.add_font_override("font", font)

func get_name():
	return recipe_name_label.text

func reset():
	recipe_name_label.text = ""
	recipe_description_label.text = ""
