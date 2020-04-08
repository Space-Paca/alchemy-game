tool
extends Node2D

signal reagent_placed

const HANDSLOT = preload("res://game/battle/Hand/HandSlot.tscn")
const H_MARGIN = 45
const V_MARGIN = 25
const SLOT_H_SEPARATOR = -8
const SLOT_V_SEPARATOR = -8

export var size = 10

onready var Grid = $GridContainer
onready var BG = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	Grid.rect_position = Vector2(H_MARGIN, V_MARGIN)
	Grid.add_constant_override("hseparation", SLOT_H_SEPARATOR)
	Grid.add_constant_override("vseparation", SLOT_V_SEPARATOR)

func get_width():
	assert(Grid.get_child_count() > 0)
	var slots_number = size
	var slot = Grid.get_child(1)
	return (slot.rect_size.x*slot.rect_scale.x) * slots_number/2 + 2*H_MARGIN \
			+ ((slots_number/2) - 1)*SLOT_H_SEPARATOR

func get_height():
	assert(Grid.get_child_count() > 0)
	var slot = Grid.get_child(1)
	return (slot.rect_size.y*slot.rect_scale.y) * 2 + 2*V_MARGIN \
			+ SLOT_V_SEPARATOR

func set_hand(slots):
	size = slots
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = slots/2
	for _i in range(slots):
		Grid.add_child(HANDSLOT.instance())

	BG.rect_size.x = get_width()
	BG.rect_size.y = get_height()

func available_slot_count():
	var count = 0
	for slot in Grid.get_children():
		if not slot.get_reagent():
			count += 1
	return count

#Places a reagent in an empty position, throws error if unable
func place_reagent(reagent):
	for slot in Grid.get_children():
		if not slot.get_reagent():
			slot.set_reagent(reagent)
			yield(slot, "reagent_set")
			emit_signal("reagent_placed")
			return
	push_error("Can't place reagent in hand, hand is full.")
	assert(false)
