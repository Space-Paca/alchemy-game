extends Control

signal closed
signal recipe_toggle
signal grid_modified(reagent_matrix)
signal combination_made(reagent_matrix)

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")

onready var dispenser_list = $Book/DispenserReagentList
onready var reagents = $Reagents
onready var grid = $Grid
onready var counter = $Counter
onready var recipe_name_display = $RecipeNameDisplay
onready var recipe_button = $Book/RecipesButton
#Buttons
onready var back_button = $BackButton
onready var combine_button = $Combine

var map_node : MapNode
var player
var is_dragging_reagent := false


func _ready():
	if Debug.seasonal_event:
		set_seasonal_look(Debug.seasonal_event)


func set_seasonal_look(event_string):
	var path = "res://assets/images/background/%s/" % event_string
	$Background.texture = load(path + "cauldron_bg.png")


func setup(node, _player, attempts):
	$Book/ReagentDropZone.monitorable = true
	map_node = node
	player = _player
	dispenser_list.populate(player.bag)
	grid.set_grid(player.grid_size)
	counter.set_attempts(attempts)
	$Counter/AnimationPlayer.play("default")
	recipe_name_display.reset()


func create_reagent(dispenser, type, quick_place):
	if dispenser.get_quantity() > 0 and (not quick_place or not grid.is_full()):
		dispenser.set_quantity(dispenser.get_quantity() - 1)
	else:
		AudioManager.play_sfx("error")
		return
	
	var reagent = ReagentManager.create_object(type)
	reagent.connect("started_dragging", self, "_on_reagent_drag")
	reagent.connect("stopped_dragging", self, "_on_reagent_stop_drag")
	reagent.connect("hovering", self, "_on_reagent_hover")
	reagent.connect("stopped_hovering", self, "_on_reagent_stop_hover")
	reagent.connect("quick_place", self, "_on_reagent_quick_place")
	reagent.dispenser = dispenser
	reagents.add_child(reagent)
	reagent.rect_global_position = get_viewport().get_mouse_position()
	reagent.disable_tooltips()
	
	if not quick_place:
		reagent.start_dragging()
		reagent.target_position = dispenser.get_pos()
	else:
		grid.quick_place(reagent)


func get_attempts():
	return counter.get_attempts()


func reset_room():
	map_node.set_type(MapNode.EMPTY)


func disable_player():
	$Combine.disabled = true
	$BackButton.disabled = true
	dispenser_list.disable()
	for reagent in reagents.get_children():
		reagent.can_drag = false


func enable_player():
	$Combine.disabled = false
	$BackButton.disabled = false
	dispenser_list.enable()
	for reagent in reagents.get_children():
		reagent.can_drag = true


func display_name_for_combination(combination):
	recipe_name_display.display_name_for_combination(combination, false)


func combination_success(combination: Combination):
	grid.set_combination_icon(combination.recipe.fav_icon)
	grid.set_combination_sfx(combination.recipe.sfx)
	grid.recipe_made_animation()
	var func_state = grid.dispense_reagents()
	if func_state and func_state.is_valid():
		yield(grid, "dispensed_reagents")
	
	enable_player()


func combination_failed():
	grid.misfire_animation(true)
	var func_state = grid.reposition_reagents()
	if func_state and func_state.is_valid():
		yield(grid, "repositioned_reagents")
	
	enable_player()


func recipe_book_visibility(is_visible):
	if is_visible:
		recipe_button.visible = false
		disable_player()
	else:
		recipe_button.visible = true
		enable_player()


func _on_BackButton_pressed():
	$Book/ReagentDropZone.monitorable = false
	dispenser_list.clear()
	for reagent in reagents.get_children():
		reagents.remove_child(reagent)
	
	#Reset room
	if get_attempts() <= 0:
		map_node.set_type(MapNode.EMPTY)
	
	emit_signal("closed")


func _on_reagent_drag(reagent):
	reagents.move_child(reagent, reagents.get_child_count()-1)
	is_dragging_reagent = true


func _on_reagent_stop_drag(reagent):
	is_dragging_reagent = false
	if not reagent.slot:
		reagent.return_to_dispenser()


func _on_reagent_hover(reagent):
	if not is_dragging_reagent:
		reagent.hover_effect()


func _on_reagent_stop_hover(reagent):
	if not is_dragging_reagent:
		reagent.stop_hover_effect()


func _on_reagent_quick_place(reagent):
	if reagent.slot:
		AudioManager.play_sfx("quick_place_hand")
		if reagent.slot.type == "grid":
			reagent.return_to_dispenser()


func _on_DispenserReagentList_dispenser_pressed(dispenser, reagent, quick_place):
	create_reagent(dispenser, reagent, quick_place)


func _on_Combine_pressed():
	if counter.get_attempts() <= 0 or grid.is_empty():
		AudioManager.play_sfx("error")
		if counter.get_attempts() <= 0:
			counter.blink_red()
		return
	
	grid.clear_hints()
	
	counter.decrease_attempts()
	
	var reagent_matrix := []
	var child_index := 0
	var reagent_list = []
	for _i in range(grid.grid_size):
		var line = []
		for _j in range(grid.grid_size):
			var reagent = grid.slots.get_child(child_index).current_reagent
			if reagent:
				reagent_list.append(reagent)
				line.append(reagent.type)
			else:
				line.append(null)
			child_index += 1
		reagent_matrix.append(line)
	
	disable_player()
	
	#Combination animation
	var sfx_dur = AudioManager.get_sfx_duration("combine")
	var dur = .2 if Profile.get_option("turbo_mode") else reagent_list.size()*.3
	AudioManager.play_sfx("combine", sfx_dur/dur)
	for reagent in reagent_list:
		reagent.combine_animation(grid.get_center(), dur, false)
	grid.combination_animation(dur)

	yield(reagent_list.back(), "finished_combine_animation")
	
	emit_signal("combination_made", reagent_matrix, grid.grid_size)
	

func _on_Grid_modified():
	if grid.is_empty():
		recipe_name_display.reset()
		return
	
	var reagent_matrix := []
	for i in range(grid.grid_size):
		var line = []
		for j in range(grid.grid_size):
			var reagent = grid.slots.get_child(grid.grid_size * i + j).current_reagent
			if reagent:
				line.append(reagent.type)
			else:
				line.append(null)
		reagent_matrix.append(line)
	emit_signal("grid_modified", reagent_matrix, grid.grid_size)


func _on_RecipesButton_pressed():
	emit_signal("recipe_toggle")


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_RecipesButton_mouse_entered():
	AudioManager.play_sfx("hover_tabs")
