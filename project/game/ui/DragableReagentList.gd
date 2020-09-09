extends Control

const HAND_SLOT = preload("res://game/battle/hand/HandSlot.tscn")

onready var grid = $ScrollContainer/GridContainer

func populate(reagent_bag: Array):
	for bag_reagent in reagent_bag:
		var slot = HAND_SLOT.instance()
		grid.add_child(slot)

func get_slot(index):
	return grid.get_child(index)

func clear():
	for slot in grid.get_children():
		grid.remove_child(slot)
