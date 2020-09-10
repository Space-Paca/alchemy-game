extends Control

signal closed

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")
const REST_HEAL = 70

onready var reagent_list = $Book/DispenserReagentList
onready var reagents = $Reagents
onready var grid = $Grid
onready var counter = $Counter

var map_node : MapNode
var player
var is_dragging_reagent := false

func setup(node, _player):
	map_node = node
	player = _player
	reagent_list.populate(player.bag)
	grid.set_grid(player.grid_size)

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

func reset_room():
	map_node.set_type(MapNode.EMPTY)


func _on_BackButton_pressed():
	reagent_list.clear()
	for reagent in reagents.get_children():
		reagents.remove_child(reagent)
	
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
	if counter.get_attempts() > 0 and not grid.is_empty():
		pass
	else:
		AudioManager.play_sfx("error")
