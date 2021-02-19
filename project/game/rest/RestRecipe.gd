extends Control

signal chosen(combination)

onready var choose_button = $Choose
onready var recipe_display = $RecipeDisplayBig

var combination : Combination
var player : Player

func set_combination(_combination: Combination):
	combination = _combination
	recipe_display.set_combination(combination)
	
	update_display()


func update_display():
	recipe_display.update_combination()
	


func master_combination():
	recipe_display.master_combination()


func enable_tooltips():
	recipe_display.enable_tooltips()


func disable_tooltips():
	recipe_display.disable_tooltips()


func _on_Choose_pressed():
	AudioManager.play_sfx("study_recipe")
	combination.discover_all_reagents()
	update_display()
	master_combination()
	
	choose_button.hide()
	emit_signal("chosen", self)
