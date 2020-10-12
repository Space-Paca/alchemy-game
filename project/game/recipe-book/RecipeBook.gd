extends Control
class_name RecipeBook

signal recipe_pressed(combination, mastery_unlocked)
signal favorite_toggled(combination, button_pressed)

onready var hand_rect : Control = $Background/HandRect
onready var upper_hand = $Background/HandRect/CenterContainer/HandReagents/Upper
onready var lower_hand = $Background/HandRect/CenterContainer/HandReagents/Lower
onready var draw_bag = $Background/HandRect/DrawBag
onready var discard_bag = $Background/HandRect/DiscardBag
onready var recipe_grid : GridContainer = $Background/ScrollContainer/RecipeGrid
onready var scroll : ScrollContainer = $Background/ScrollContainer
onready var hand_tag_button = $Background/TagButtons/HandBtn
onready var filter_menu = $Background/FilterMenu
onready var tween : Tween = $Tween

const RECIPE = preload("res://game/recipe-book/RecipeDisplay.tscn")
const REAGENT_DISPLAY = preload("res://game/recipe-book/ReagentDisplay.tscn")

enum States {BATTLE, MAP, LAB}
enum {DECK, HAND, INCOMPLETE, COMPLETE, ALL}

var recipe_displays := {}
var hand_reagents : Array
var state : int = States.MAP
var battle_draw_bag
var battle_discard_bag
var player : Player


func change_state(new_state: int):
	if new_state == state:
		return
	
	match new_state:
		States.BATTLE:
			hand_rect.visible = true
			scroll.rect_size.y -= hand_rect.rect_size.y
			draw_bag.disable()
			discard_bag.disable()
			hand_tag_button.show()
			reset_recipe_visibility()
		States.MAP:
			if state == States.BATTLE:
				remove_hand()
				scroll.rect_size.y += hand_rect.rect_size.y
				hand_tag_button.hide()
				reset_recipe_visibility()
		States.LAB:
			pass
	
	state = new_state


func add_combination(combination: Combination, position: int, threshold: int):
	if recipe_displays.has(combination.recipe.name):
		print("RecipeBook.gd add_combination recipe %s already exists" % combination.recipe.name)
		return
	
	var recipe_display = RECIPE.instance()
	recipe_grid.add_child(recipe_display)
	recipe_grid.move_child(recipe_display, position)
	recipe_display.set_combination(combination)
	recipe_display.connect("hovered", self, "_on_recipe_display_hovered")
	recipe_display.connect("unhovered", self, "_on_recipe_display_unhovered")
	recipe_display.connect("pressed", self, "_on_recipe_display_pressed")
	recipe_display.connect("favorite_toggled", self, "_on_recipe_display_favorite_toggled")
	recipe_displays[combination.recipe.name] = recipe_display
	
	recipe_display.update_mastery(0, threshold)


func update_combination(combination: Combination):
	assert(recipe_displays.has(combination.recipe.name),"RecipeBook.gd update_combination: %s not in recipe book" % combination.recipe.name)
	var display = recipe_displays[combination.recipe.name]
	display.update_combination()


func create_hand(battle):
	var rows = [upper_hand, lower_hand]
	hand_reagents = []
	battle_draw_bag = battle.draw_bag
	battle_discard_bag = battle.discard_bag
	battle.connect("current_reagents_updated", self, "update_hand")
	for i in range(battle.hand.size):
		var reagent = REAGENT_DISPLAY.instance()
		var row = 0 if i < ceil(battle.hand.size / 2.0) else 1
		reagent.rect_min_size = Vector2(80, 80)
		hand_reagents.append(reagent)
		rows[row].add_child(reagent)


func remove_hand():
	for child in upper_hand.get_children():
		upper_hand.remove_child(child)
	for child in lower_hand.get_children():
		lower_hand.remove_child(child)
	
	hand_rect.visible = false


func toggle_visibility():
	visible = !visible
	
	if visible:
		AudioManager.play_sfx("open_recipe_book")
	else:
		AudioManager.play_sfx("close_recipe_book")
		_on_recipe_display_unhovered()
	
	if state == States.BATTLE:
		if visible:
			update_bags()
			draw_bag.enable()
			discard_bag.enable()
		else:
			draw_bag.disable()
			discard_bag.disable()
	
	return visible


func is_mastered(combination : Combination):
	return recipe_displays[combination.recipe.name].is_mastered()
	

func unlock_mastery(combination: Combination):
	recipe_displays[combination.recipe.name].unlock_mastery()


func update_mastery(combination: Combination, current_value: int, threshold: int):
	recipe_displays[combination.recipe.name].update_mastery(current_value, threshold)


func update_hand(reagents: Array):
	for i in reagents.size():
		hand_reagents[i].set_reagent(reagents[i])


func update_bags():
	draw_bag.copy_bag(battle_draw_bag)
	discard_bag.copy_bag(battle_discard_bag)


func color_hand_reagents(reagent_array: Array):
	var reagents := reagent_array.duplicate()
	var correct_reagent_displays := []
	var i = 0
	while not reagents.empty() and i < hand_reagents.size():
		var reagent = hand_reagents[i].reagent_name
		for other in reagents:
			if reagent == other:
				correct_reagent_displays.append(hand_reagents[i])
				reagents.erase(other)
				break
		i += 1
	
	if reagents.empty():
		for display in correct_reagent_displays:
			display.self_modulate = Color.green


func reset_hand_reagents_color():
	for display in hand_reagents:
		display.self_modulate = Color.white


func favorite_error(combination: Combination):
	recipe_displays[combination.recipe.name].favorite_error()


func error_effect():
	AudioManager.play_sfx("error")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(hand_rect, "modulate", Color.red, Color.white,
			.5, Tween.TRANS_SINE, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()


func get_combinations() -> Array:
	var combinations := []
	for recipe_display in recipe_displays.values():
		combinations.append(recipe_display.combination)
	
	return combinations


func get_hand_reagents():
	var available_reagents = []
	for reagent_display in hand_reagents:
		available_reagents.append(reagent_display.reagent_name)
	
	return available_reagents


func get_player_reagents():
	var available_reagents = []
	if state == States.BATTLE:
		available_reagents += get_hand_reagents()
		available_reagents += draw_bag.get_reagent_names()
		available_reagents += discard_bag.get_reagent_names()
	else:
		for reagent in player.bag:
			available_reagents.append(reagent.type)
	
	return available_reagents


func filter_combinations(combinations : Array, filters : Array):
	var filtered_combinations = []
	
	for combination in combinations:
		for recipe_filter in combination.recipe.filters:
			for filter in filters:
				if filter == recipe_filter:
					filtered_combinations.append(combination)
					break
	
	return filtered_combinations


#Given an array of combinations and and array of reagents, returns all combinations
#from the list that can be made with given reagents
func get_valid_combinations(combinations : Array, available_reagents : Array):
	var valid_combinations = []
	for combination in combinations:
		var reagents = available_reagents.duplicate()
		var valid_combination = true
		for comb_reagent in combination.recipe.reagents:
			if reagents.find(comb_reagent) != -1:
				reagents.remove(reagents.find(comb_reagent))
			else:
				valid_combination = false
				break
		if valid_combination:
			valid_combinations.append(combination)
	
	return valid_combinations


func get_combination_completion(combinations: Array, complete: bool):
	var ret_combinations := []
	for combination in combinations:
		if combination.discovered == complete:
			ret_combinations.append(combination)
	
	return ret_combinations


func filter_by_tag(tag: int):
	var all_combinations := get_combinations()
	var to_tag := []
	match tag:
		DECK:
			to_tag = get_valid_combinations(all_combinations, get_player_reagents())
		HAND:
			to_tag = get_valid_combinations(all_combinations, get_hand_reagents())
		INCOMPLETE:
			to_tag = get_combination_completion(all_combinations, false)
		COMPLETE:
			to_tag = get_combination_completion(all_combinations, true)
		ALL:
			tag_all_combinations()
			update_recipes_shown()
			return
	
	for recipe_display in recipe_displays.values():
		recipe_display.tagged = to_tag.has(recipe_display.combination)
	
	update_recipes_shown()


func tag_all_combinations():
	for recipe_display in recipe_displays.values():
		recipe_display.tagged = true


func update_recipes_shown():
	for recipe_display in recipe_displays.values():
		recipe_display.visible = recipe_display.tagged and recipe_display.filtered


func reset_recipe_visibility():
	for recipe_display in recipe_displays.values():
		recipe_display.tagged = true
		recipe_display.filtered = true
		recipe_display.show()


func _on_recipe_display_hovered(reagent_array: Array):
	if state == States.BATTLE:
		color_hand_reagents(reagent_array)


func _on_recipe_display_unhovered():
	if state == States.BATTLE:
		reset_hand_reagents_color()


func _on_recipe_display_pressed(combination: Combination, mastery_unlocked: bool):
	if state != States.BATTLE:
		return
	
	if not hand_reagents.size():
		error_effect()
		return
	
	var combination_reagents : Array = combination.recipe.reagents.duplicate()
	
	var i = 0
	while not combination_reagents.empty() and i < hand_reagents.size():
		var reagent = hand_reagents[i].reagent_name
		for other in combination_reagents:
			if reagent == other:
				combination_reagents.erase(other)
				break
		i += 1
	
	if combination_reagents.empty():
		emit_signal("recipe_pressed", combination, mastery_unlocked)
	else:
		error_effect()


func _on_recipe_display_favorite_toggled(combination: Combination, button_pressed: bool):
	emit_signal("favorite_toggled", combination, button_pressed)


func _on_Tag_pressed(tag: int):
	filter_by_tag(tag)


func _on_FilterMenu_filters_updated(values):
	pass # Replace with function body.
