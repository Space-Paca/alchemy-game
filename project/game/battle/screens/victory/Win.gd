extends CanvasLayer

signal continue_pressed
signal combinations_seen(combinations)
signal combination_chosen(combination)
signal reagent_looted(reagent_name)
signal reagent_sold(gold_value)
signal gem_collected(quantity)

onready var loot_list = $BG/MovingScreen/ScrollContainer/RewardsContainer/LootList
onready var gem_container = $BG/MovingScreen/ScrollContainer/RewardsContainer/GemContainer
onready var rewards_container = $BG/MovingScreen/ScrollContainer
onready var recipes_container = $BG/MovingScreen/RecipesContainer
onready var recipe_displays = [$BG/MovingScreen/RecipesContainer/WinRecipe1,
		$BG/MovingScreen/RecipesContainer/WinRecipe2,
		$BG/MovingScreen/RecipesContainer/WinRecipe3]
onready var back_button = $BG/MovingScreen/RecipesContainer/BackButton
onready var recipes_button = $BG/MovingScreen/ScrollContainer/RewardsContainer/RecipesButton
onready var continue_button = $BG/MovingScreen/ContinueButton
onready var gem_label = $BG/MovingScreen/ScrollContainer/RewardsContainer/GemContainer/Label
onready var moving_screen = $BG/MovingScreen
onready var bg = $BG
onready var tween = $Tween

enum States {LOOT, RECIPE}

const MOVE_DURATION = .5
const MOVE_POS = [0, -1920]
const REAGENT_LOOT = preload("res://game/battle/screens/victory/ReagentLoot.tscn")

var curr_state : int = States.LOOT
var rewarded_combinations := []
var gem_amount := 0
var player = null

func setup(_player):
	player = _player

func set_loot(loot: Array):
	for loot_name in loot:
		if loot_name in ReagentDB.get_types():
			var reagent_loot = REAGENT_LOOT.instance()
			loot_list.add_child(reagent_loot)
			reagent_loot.connect("reagent_looted", self, "_on_reagent_looted")
			reagent_loot.connect("reagent_sold", self, "_on_reagent_sold")
			reagent_loot.set_reagent(loot_name)
		elif loot_name == "gem":
			if player.has_artifact("elite_drop"):
				gem_amount += 2
			else:
				gem_amount += 1
	
	if gem_amount:
		gem_container.show()
		gem_label.text = str("x ", gem_amount)
	
	disable_buttons()


func set_combinations(combinations: Array):
	for i in range(recipe_displays.size()):
		if i < combinations.size() and combinations[i]:
			recipe_displays[i].set_combination(combinations[i])
			rewarded_combinations.append(combinations[i])
		else:
			if i == 0:
				recipes_button.hide()
			print("Win.gd: Not enough combinations to fill victory screen")
			recipe_displays[i].hide()
	


func display():
	bg.show()
	enable_buttons()


func change_state(new_state:int):
	if curr_state == new_state:
		return
	
	curr_state = new_state
	move_screen()


func move_screen():
	var target_pos_x = MOVE_POS[curr_state]
	disable_buttons()
	
	tween.interpolate_property(moving_screen, "rect_position:x", null,
			target_pos_x, MOVE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	
	enable_buttons()


func disable_buttons():
	for recipe in recipe_displays:
		recipe.disable_button()
	
	for loot in loot_list.get_children():
		loot.disable_buttons()
	
	continue_button.disabled = true
	back_button.disabled = true
	recipes_button.disabled = true


func enable_buttons():
	match curr_state:
		States.LOOT:
			for loot in loot_list.get_children():
				loot.enable_buttons()
			continue_button.disabled = false
			recipes_button.disabled = false
		States.RECIPE:
			for recipe in recipe_displays:
				recipe.enable_button()
			back_button.disabled = false


func _on_ContinueButton_pressed():
	emit_signal("continue_pressed")


func _on_reagent_looted(reagent_loot):
	AudioManager.play_sfx("get_loot")
	emit_signal("reagent_looted", reagent_loot.reagent)
	reagent_loot.queue_free()


func _on_reagent_sold(reagent_loot):
	emit_signal("reagent_sold", reagent_loot.gold_value)
	reagent_loot.queue_free()


func _on_gem_collected():
	emit_signal("gem_collected", gem_amount)
	gem_container.hide()


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_WinRecipe_chosen(chosen_recipe):
	for recipe_display in recipe_displays:
		if recipe_display != chosen_recipe:
			recipe_display.hide()
	
	recipes_button.hide()
	back_button.hide()
	
	tween.interpolate_property(chosen_recipe, "rect_position:x", null, 1264,
			MOVE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(recipes_container, "rect_position:x", null, 0,
			MOVE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(rewards_container, "rect_position:x", null, 400,
			MOVE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	change_state(States.LOOT)
	
	emit_signal("combination_chosen", chosen_recipe.combination)


func _on_BackButton_pressed():
	change_state(States.LOOT)


func _on_RecipesButton_pressed():
	change_state(States.RECIPE)
	emit_signal("combinations_seen", rewarded_combinations)
