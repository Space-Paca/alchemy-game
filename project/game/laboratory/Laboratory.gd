extends Control

signal closed
signal grid_modified(reagent_matrix)
signal combination_made(reagent_matrix)

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")
const REST_HEAL = 70

onready var dispenser_list = $Book/DispenserReagentList
onready var reagents = $Reagents
onready var grid = $Grid
onready var counter = $Counter
onready var recipe_name_display = $RecipeNameDisplay

var map_node : MapNode
var player
var is_dragging_reagent := false

func setup(node, _player, attempts):
	map_node = node
	player = _player
	dispenser_list.populate(player.bag)
	grid.set_grid(player.grid_size)
	counter.set_attempts(attempts)

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
	reagent.disable() #Blocks tooltips
	
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

func enable_player():
	$Combine.disabled = false
	$BackButton.disabled = false
	dispenser_list.enable()

func display_name_for_combination(combination):
	recipe_name_display.display_name_for_combination(combination)

func combination_success():
	var func_state = grid.dispense_reagents()
	if func_state and func_state.is_valid():
		yield(grid, "dispensed_reagents")
	
	enable_player()

func combination_failed():
	var func_state = grid.reposition_reagents()
	if func_state and func_state.is_valid():
		yield(grid, "repositioned_reagents")
	
	enable_player()

func _on_BackButton_pressed():
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
	
	grid.clear_hint()
	
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
	var dur = reagent_list.size()*.3
	AudioManager.play_sfx("combine", sfx_dur/dur)
	for reagent in reagent_list:
		reagent.combine_animation(grid.get_center(), dur)

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

