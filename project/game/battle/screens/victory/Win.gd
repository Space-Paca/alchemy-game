extends CanvasLayer

signal continue_pressed
#signal combination_chosen(combination)
signal reagent_looted(reagent_name)
signal reagent_sold(gold_value)

onready var loot_list = $BG/CenterContainer/HBoxContainer/RewardsContainer/LootList
onready var gold_label = $BG/CenterContainer/HBoxContainer/RewardsContainer/LootList/GoldReward/GoldLabel
onready var rewards_container = $BG/CenterContainer/HBoxContainer/RewardsContainer
onready var recipe_displays = [$BG/CenterContainer/HBoxContainer/WinRecipe1, $BG/CenterContainer/HBoxContainer/WinRecipe2, $BG/CenterContainer/HBoxContainer/WinRecipe3]
onready var bg = $BG

const REAGENT_LOOT = preload("res://game/battle/screens/victory/ReagentLoot.tscn")

var rewarded_combinations := []


func set_loot(gold: int, loot: Array):
	gold_label.text = str(gold)
	
	for reagent_name in loot:
		var reagent_loot = REAGENT_LOOT.instance()
		loot_list.add_child(reagent_loot)
		reagent_loot.connect("reagent_looted", self, "_on_reagent_looted")
		reagent_loot.connect("reagent_sold", self, "_on_reagent_sold")
		reagent_loot.set_reagent(reagent_name)


func show(combinations: Array):
	for i in range(recipe_displays.size()):
		if i < combinations.size() and combinations[i]:
			recipe_displays[i].set_combination(combinations[i])
			rewarded_combinations.append(combinations[i])
		else:
			if i == 0:
				rewards_container.show()
			print("Win.gd: Not enough combinations to fill victory screen")
			recipe_displays[i].hide()
	
	bg.show()


func _on_Button_pressed():
	emit_signal("continue_pressed")


func _on_reagent_looted(reagent_loot):
	AudioManager.play_sfx("get_loot")
	emit_signal("reagent_looted", reagent_loot.reagent)
	reagent_loot.queue_free()


func _on_reagent_sold(reagent_loot):
	emit_signal("reagent_sold", reagent_loot.gold_value)
	reagent_loot.queue_free()


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_Button_mouse_entered():
		AudioManager.play_sfx("hover_button")


func _on_WinRecipe_chosen(chosen_recipe):
	for recipe_display in recipe_displays:
		if recipe_display != chosen_recipe:
			recipe_display.hide()
	
	rewards_container.show()
	
#	emit_signal("combination_chosen", chosen_recipe.combination)
