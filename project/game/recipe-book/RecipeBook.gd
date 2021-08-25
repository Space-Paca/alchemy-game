extends Control
class_name RecipeBook

signal recipe_pressed(combination, mastery_unlocked)
signal recipe_pressed_lab(combination)
signal favorite_toggled(combination, button_pressed)
signal close

onready var hand_rect : Control = $Background/HandRect
onready var hand_container : Control = $Background/HandRect/CenterContainer
onready var upper_hand = $Background/HandRect/CenterContainer/HandReagents/Upper
onready var lower_hand = $Background/HandRect/CenterContainer/HandReagents/Lower
onready var draw_bag = $Background/HandRect/DrawBag
onready var discard_bag = $Background/HandRect/DiscardBag
onready var recipe_grid : GridContainer = $Background/ScrollContainer/RecipeGrid
onready var scroll : ScrollContainer = $Background/ScrollContainer
onready var lower_divider = $Background/LowerDivider
onready var hand_tag_button = $Background/TagButtons/HandBtn
onready var filter_menu = $Background/FilterMenu
onready var no_recipes_label = $Background/NothingFound
onready var reagent_container = $Background/LeftSide/ScrollContainer/ReagentContainer
onready var tween : Tween = $Tween

const RECIPE = preload("res://game/recipe-book/RecipeDisplay.tscn")
const REAGENT_DISPLAY = preload("res://game/recipe-book/ReagentDisplay.tscn")
const LONG_TAG_TEXTURE = preload("res://assets/images/ui/book/book_tag_btn.png")
const SHORT_TAG_TEXTURE = preload("res://assets/images/ui/book/book_tag_btn_short.png")
const LONG_TAG_HOVER_TEXTURE = preload("res://assets/images/ui/book/book_tag_btn_hover.png")
const SHORT_TAG_HOVER_TEXTURE = preload("res://assets/images/ui/book/book_tag_btn_short_hover.png")
const CLICKABLE_REAGENT = preload("res://game/ui/ClickableReagent.tscn")
const ACTIVE_TAG_LABEL_POS = 110
const INACTIVE_TAG_LABEL_POS = 53
const BATTLE_POS = Vector2.ZERO
const MAP_POS = Vector2(820, 0)
const NOTHING_FOUND_LABEL_SPEED = 3

enum States {BATTLE, MAP, LAB}
enum {HAND, DECK, INCOMPLETE, COMPLETE, ALL}

var recipe_displays := {}
var favorite_combinations := []
var hand_reagents : Array
var current_tag := HAND
var state : int = States.MAP
var battle_draw_bag
var battle_discard_bag
var player : Player


func _ready():
	discard_bag.disable()
	draw_bag.disable()
	disable_tooltips()
	no_recipes_label.modulate.a = 0


func _process(dt):
	if no_recipes_found():
		no_recipes_label.modulate.a = min(no_recipes_label.modulate.a + NOTHING_FOUND_LABEL_SPEED*dt, 1)
	else:
		no_recipes_label.modulate.a = 0


func update_player_info():
	$Background/LeftSide/PlayerInfo.update_values(player)

func set_player(p: Player):
	player = p
	$Background/LeftSide/PlayerInfo.set_player(p)
	update_reagents(player.bag)


func change_state(new_state: int):
	if new_state == state:
		return
	
	match new_state:
		States.BATTLE:
			rect_position = BATTLE_POS
			hand_rect.visible = true
			scroll.rect_size.y -= hand_rect.rect_size.y
			lower_divider.show()
			draw_bag.disable()
			discard_bag.disable()
			hand_tag_button.show()
			reset_recipe_visibility()
		States.MAP:
			if state == States.BATTLE:
				rect_position = MAP_POS
				remove_hand()
				lower_divider.hide()
				scroll.rect_size.y += hand_rect.rect_size.y
				hand_tag_button.hide()
				reset_recipe_visibility()
				filter_by_tag(DECK)
				update_tag_buttons(DECK)
		States.LAB:
			reset_recipe_visibility()
			filter_by_tag(INCOMPLETE)
			update_tag_buttons(INCOMPLETE)
	
	state = new_state


func reapply_tag_and_filters():
	filter_by_tag(current_tag)
	filter_menu.reapply_filters()


func set_favorite_button(combination, pressed, temp_disconnect = false):
	assert(recipe_displays.has(combination.recipe.id), "Doesn't have this recipe display:" + str(combination.recipe.id))
	recipe_displays[combination.recipe.id].set_favorite_button(pressed, temp_disconnect)


func add_combination(combination: Combination, threshold: int):
	if recipe_displays.has(combination.recipe.id):
		print("RecipeBook.gd add_combination recipe %s already exists" % combination.recipe.id)
		return
	
	var recipe_display = RECIPE.instance()
	recipe_grid.add_child(recipe_display)
	recipe_display.set_combination(combination)
	recipe_display.connect("hovered", self, "_on_recipe_display_hovered")
	recipe_display.connect("unhovered", self, "_on_recipe_display_unhovered")
	recipe_display.connect("pressed", self, "_on_recipe_display_pressed")
	recipe_display.connect("favorite_toggled", self, "_on_recipe_display_favorite_toggled")
	recipe_displays[combination.recipe.id] = recipe_display
	
	recipe_display.update_mastery(0, threshold)


func update_combination(combination: Combination):
	assert(recipe_displays.has(combination.recipe.id),"RecipeBook.gd update_combination: %s not in recipe book" % combination.recipe.id)
	recipe_displays[combination.recipe.id].update_combination()


func update_reagents(bag):
	for child in reagent_container.get_children():
		reagent_container.remove_child(child)
	
	for reagent in bag:
		var clickable_reagent = CLICKABLE_REAGENT.instance()
		var texture = ReagentDB.get_from_name(reagent.type).image
		clickable_reagent.setup(texture, reagent.upgraded, reagent.type)
		reagent_container.add_child(clickable_reagent)


func create_hand(battle):
	var rows = [upper_hand, lower_hand]
	hand_reagents = []
	battle_draw_bag = battle.draw_bag
	battle_discard_bag = battle.discard_bag
	battle.connect("current_reagents_updated", self, "update_hand")
	battle.connect("hand_set", self, "_on_battle_hand_set")
	for i in range(battle.hand.size):
		var reagent = REAGENT_DISPLAY.instance()
		reagent.set_mode("hand")
		var row = 0 if i < ceil(battle.hand.size / 2.0) else 1
		reagent.rect_min_size = Vector2(80, 80)
		hand_reagents.append(reagent)
		rows[row].add_child(reagent)
	if battle.hand.size > 10:
		if hand_container.rect_scale == Vector2(1, 1):
			hand_container.rect_scale = Vector2(.8, .8)
			hand_container.rect_position += (hand_container.rect_size*.2)/2
	else:
		if hand_container.rect_scale == Vector2(.8, .8):
			hand_container.rect_scale = Vector2(1, 1)
			hand_container.rect_position -= (hand_container.rect_size*.2)/2
	
	if visible:
		enable_tooltips()
	


func remove_hand():
	for child in upper_hand.get_children():
		upper_hand.remove_child(child)
	for child in lower_hand.get_children():
		lower_hand.remove_child(child)
	
	draw_bag.disable()
	discard_bag.disable()
	hand_rect.visible = false


func enable_tooltips():
	#Hand reagents
	for display in hand_reagents:
		display.enable_tooltips()
	#Recipes
	for display in recipe_grid.get_children():
		if display.visible:
			display.enable_tooltips()
		else:
			display.disable_tooltips()
	#Bag reagents
	for reagent in reagent_container.get_children():
		reagent.enable_tooltips()
	#Player info
	$Background/LeftSide/PlayerInfo.enable_tooltips()


func disable_tooltips():
	#Hand reagents
	for display in hand_reagents:
		display.disable_tooltips()
	#Recipes
	for display in recipe_grid.get_children():
		display.disable_tooltips()
	#Bag reagents
	for reagent in reagent_container.get_children():
		reagent.disable_tooltips()
	#Player info
	$Background/LeftSide/PlayerInfo.disable_tooltips()


func toggle_visibility():
	visible = !visible
	
	if visible:
		AudioManager.play_sfx("open_recipe_book")
		enable_tooltips()
		
		if not Profile.get_tutorial("recipe_book"):
			$Background/CloseButton.disabled = true
		else:
			$Background/CloseButton.disabled = false
	else:
		AudioManager.play_sfx("close_recipe_book")
		disable_tooltips()
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
	return recipe_displays[combination.recipe.id].is_mastered()
	

func unlock_mastery(combination: Combination, show_message := true):
	if recipe_displays[combination.recipe.id].unlock_mastery(show_message,
			favorite_combinations.has(combination)):
		player.increase_stat("recipes_mastered")


func update_mastery(combination: Combination, current_value: int, threshold: int):
	recipe_displays[combination.recipe.id].update_mastery(current_value, threshold)


func update_hand(reagents: Array):
	for i in reagents.size():
		hand_reagents[i].set_reagent(reagents[i])
	reapply_tag_and_filters()
	if visible:
		enable_tooltips()


func update_bags():
	draw_bag.copy_bag(battle_draw_bag)
	discard_bag.copy_bag(battle_discard_bag)

func color_hand_reagents(reagent_array: Array):
	var hand_array = []
	for reagent_display in hand_reagents:
		hand_array.append(reagent_display.reagent_name)
	var correct_reagents = ReagentManager.get_reagents_to_use(reagent_array, hand_array)
	if correct_reagents:
		for index in correct_reagents.size():
			if correct_reagents[index]:
				var display = hand_reagents[index]
				display.self_modulate = Color.green


func reset_hand_reagents_color():
	for display in hand_reagents:
		display.self_modulate = Color.white


func favorite_error(combination: Combination):
	recipe_displays[combination.recipe.id].favorite_error()


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


func filter_combinations(filters: Array):
	for recipe_display in recipe_displays.values():
		var filtered = true
		for filter in filters:
			if not filter in recipe_display.combination.recipe.filters:
				filtered = false
				break
		recipe_display.filtered = filtered
	
	update_recipes_shown()


#Given an array of combinations and and array of reagents, returns all combinations
#from the list that can be made with given reagents
func get_valid_combinations(combinations : Array, available_reagents : Array):
	var valid_combinations = []
	for combination in combinations:
		for possible_reagent_combination in combination.recipe.reagent_combinations:
			if has_necessary_reagents(possible_reagent_combination, available_reagents):
				valid_combinations.append(combination)
				break
	
	return valid_combinations


func has_necessary_reagents(reagent_array, available_reagents):
	var array = reagent_array.duplicate()
	for reagent in available_reagents:
		array.erase(reagent)
	return array.empty()

func get_combination_completion(combinations: Array, complete: bool):
	var ret_combinations := []
	for combination in combinations:
		if combination.discovered == complete:
			ret_combinations.append(combination)
	
	return ret_combinations


func filter_by_tag(tag: int):
	current_tag = tag
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


func no_recipes_found():
	for recipe_display in recipe_displays.values():
		if recipe_display.visible:
			return false
	return true


func tag_all_combinations():
	for recipe_display in recipe_displays.values():
		recipe_display.tagged = true


func update_recipes_shown():
	for recipe_display in recipe_displays.values():
		recipe_display.visible = recipe_display.tagged and recipe_display.filtered
	if visible:
		enable_tooltips()


func reset_recipe_visibility():
	filter_menu.clear_filters()
	
	for recipe_display in recipe_displays.values():
		recipe_display.tagged = true
		recipe_display.filtered = true
		recipe_display.show()


func update_tag_buttons(tag):
	for idx in range($Background/TagButtons.get_child_count()):
		var button = $Background/TagButtons.get_child(idx)
		if idx == tag:
			button.texture_normal = LONG_TAG_TEXTURE
			button.texture_hover = LONG_TAG_HOVER_TEXTURE
			button.get_node("Label").rect_position.x = ACTIVE_TAG_LABEL_POS
		else:
			button.texture_normal = SHORT_TAG_TEXTURE
			button.texture_hover = SHORT_TAG_HOVER_TEXTURE
			button.get_node("Label").rect_position.x = INACTIVE_TAG_LABEL_POS


func _on_recipe_display_hovered(reagent_array: Array):
	if state == States.BATTLE:
		color_hand_reagents(reagent_array)


func _on_recipe_display_unhovered():
	if state == States.BATTLE:
		reset_hand_reagents_color()


func _on_recipe_display_pressed(combination: Combination, mastery_unlocked: bool):
	if state != States.BATTLE and state != States.LAB:
		return
	if state == States.BATTLE:
		if not hand_reagents.size():
			error_effect()
			return
		
		var combination_reagents = combination.recipe.reagents.duplicate()
		var hand_array = []
		for reagent_display in hand_reagents:
			hand_array.append(reagent_display.reagent_name)
		var valid_reagents = ReagentManager.get_reagents_to_use(combination_reagents, hand_array)
		if valid_reagents:
			emit_signal("recipe_pressed", combination, mastery_unlocked)
		else:
			error_effect()
	else:
		emit_signal("recipe_pressed_lab", combination)


func _on_recipe_display_favorite_toggled(combination: Combination, button_pressed: bool):
	emit_signal("favorite_toggled", combination, button_pressed)


func _on_battle_hand_set():
	filter_by_tag(HAND)
	update_tag_buttons(HAND)


func _on_Tag_pressed(tag: int):
	AudioManager.play_sfx("open_recipe_book")
	filter_by_tag(tag)
	update_tag_buttons(tag)


func _on_FilterMenu_filters_updated(filters: Array):
	filter_combinations(filters)


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_CloseButton_pressed():
	emit_signal("close")
