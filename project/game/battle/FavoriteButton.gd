extends Control
class_name FavoriteButton

signal pressed

onready var button = $Button

var combination : Combination
var reagent_array : Array


func set_combination(new_combination: Combination):
	combination = new_combination
	if combination:
		button.texture_normal = combination.recipe.fav_icon
		reagent_array = combination.recipe.reagents


func enable():
	button.disabled = false


func disable():
	button.disabled = true


func hide_button():
	button.visible = false


func show_button():
	button.visible = true


func _on_Button_pressed():
	emit_signal("pressed")

