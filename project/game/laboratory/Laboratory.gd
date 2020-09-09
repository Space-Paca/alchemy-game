extends Control

signal closed

const RECIPE = preload("res://game/battle/screens/victory/WinRecipe.tscn")
const REST_HEAL = 70

onready var reagent_list = $Book/DragableReagentList
onready var reagents = $Reagents

var map_node : MapNode
var player
var is_dragging_reagent := false


func setup(node, _player):
	map_node = node
	player = _player
	reagent_list.populate(player.bag)
	#Wait a bit so slots are properly positioned in the grid, so we can teleport reagents to slot
	yield(get_tree(), "idle_frame")
	populate_reagents()

func populate_reagents():
	for i in range(0, player.bag.size()):
		var reagent = create_reagent(player.bag[i].type, player.bag[i].upgraded)
		reagents.add_child(reagent)
		var slot = reagent_list.get_slot(i)
		slot.set_reagent(reagent)
		reagents.get_child(i).rect_global_position = slot.get_pos()

func create_reagent(type, upgraded):
	var reagent = ReagentManager.create_object(type)
	reagent.connect("started_dragging", self, "_on_reagent_drag")
	reagent.connect("stopped_dragging", self, "_on_reagent_stop_drag")
	reagent.connect("hovering", self, "_on_reagent_hover")
	reagent.connect("stopped_hovering", self, "_on_reagent_stop_hover")
	reagent.connect("quick_place", self, "_on_reagent_quick_place")
	if upgraded:
		reagent.upgrade()
		
	return reagent

func place_reagent_in_book(reagent):
	pass

func place_reagent_in_grid(reagent):
	pass

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


func _on_reagent_stop_drag(_reagent):
	is_dragging_reagent = false


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
				place_reagent_in_book(reagent)
		elif reagent.slot.type == "hand":
			AudioManager.play_sfx("quick_place_grid")
			place_reagent_in_grid(reagent)

