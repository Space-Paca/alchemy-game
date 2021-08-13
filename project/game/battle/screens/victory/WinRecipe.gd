extends TextureRect

signal chosen

onready var recipe_display = $RecipeDisplayBig
onready var choose_button = $ChooseButton

var combination : Combination
var discover_all = false


func enable_tooltips():
	recipe_display.enable_tooltips()


func disable_tooltips():
	recipe_display.disable_tooltips()


func set_combination(_combination: Combination):
	combination = _combination
	
	# BUTTON TEXT
	if discover_all or combination.hints >= 2:
		choose_button.text = "Learn"
		discover_all = true
	
	recipe_display.set_combination(combination)


func disable_button():
	choose_button.disabled = true


func enable_button():
	choose_button.disabled = false


func _on_ChooseButton_pressed():
	if not discover_all:
		combination.get_hint("win_battle_hint",2)
	else:
		combination.discover_all_reagents("battle_win")
	
	if not combination.discovered:
		AudioManager.play_sfx("discover_clue_recipe")
	else:
		AudioManager.play_sfx("discover_new_recipe")
	
	recipe_display.update_combination()
	
	choose_button.hide()
	emit_signal("chosen", self)
