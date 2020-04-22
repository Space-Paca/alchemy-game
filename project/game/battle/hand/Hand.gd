tool
extends Node2D

signal reagent_placed

onready var grid = $GridContainer
onready var bg = $TextureRect

const HANDSLOT = preload("res://game/battle/hand/HandSlot.tscn")
const H_MARGIN = 45
const V_MARGIN = 25
const SLOT_H_SEPARATOR = -8
const SLOT_V_SEPARATOR = -8

export var size = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	grid.rect_position = Vector2(H_MARGIN, V_MARGIN)
	grid.add_constant_override("hseparation", SLOT_H_SEPARATOR)
	grid.add_constant_override("vseparation", SLOT_V_SEPARATOR)

func get_width():
	assert(grid.get_child_count() > 0)
	var slots_number = size
	var slot = grid.get_child(1)
	return (slot.rect_size.x*slot.rect_scale.x) * slots_number/2 + 2*H_MARGIN \
			+ ((slots_number/2) - 1)*SLOT_H_SEPARATOR

func get_height():
	assert(grid.get_child_count() > 0)
	var slot = grid.get_child(1)
	return (slot.rect_size.y*slot.rect_scale.y) * 2 + 2*V_MARGIN \
			+ SLOT_V_SEPARATOR

func set_hand(slots):
	size = slots
	for child in grid.get_children():
		grid.remove_child(child)
	grid.columns = slots/2
	for _i in range(slots):
		grid.add_child(HANDSLOT.instance())

	bg.rect_size.x = get_width()
	bg.rect_size.y = get_height()

func available_slot_count():
	var count = 0
	for slot in grid.get_children():
		if not slot.get_reagent():
			count += 1
	return count

#Places a reagent in an empty position, throws error if unable
func place_reagent(reagent):
	for slot in grid.get_children():
		if not slot.get_reagent():
			slot.set_reagent(reagent)
			yield(slot, "reagent_set")
			emit_signal("reagent_placed")
			return
	push_error("Can't place reagent in hand, hand is full.")
	assert(false)


func get_reagent_names() -> Array:
	var reagents := []
	for slot in grid.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			reagents.append(reagent.type)
		else:
			reagents.append(null)
	return reagents
