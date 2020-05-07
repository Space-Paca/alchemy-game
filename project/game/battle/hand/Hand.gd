tool
extends Node2D

signal reagent_placed
signal hand_slot_reagent_set

onready var slots = $Slots

const HANDSLOT = preload("res://game/battle/hand/HandSlot.tscn")
const H_SEPARATION = 0
const V_OFFSET = 20

var size : int


# Called when the node enters the scene tree for the first time.
func _ready():
	set_hand(8)


func get_width():
	assert(slots.get_child_count() > 0)
	var slot = slots.get_child(0)
	# warning-ignore:integer_division
	var n = size/2
	return slot.rect_size.x*n + H_SEPARATION*(n-1)


func get_height():
	assert(slots.get_child_count() > 0)
	var slot = slots.get_child(0)
	return slot.rect_size.y * 2


func set_hand(number: int):
	if number <= 0 or number%2 != 0:
		push_error("Not a valid hand size: "+ str(slots))
		assert(false)
	size = number
	for child in slots.get_children():
		slots.remove_child(child)
	
	var temp_hand_slot = HANDSLOT.instance()
	# warning-ignore:integer_division
	var n = size/2
	var x = -(temp_hand_slot.rect_size.x*n + H_SEPARATION*(n-1))/2
	var y = (max(number - 4, 0)/4) * -V_OFFSET
	
	# warning-ignore:integer_division
	for i in range(1, number/2 + 1):
		#Add top slot
		var hand_slot = HANDSLOT.instance()
		hand_slot.connect("reagent_set", self, "_on_reagent_set")
		slots.add_child(hand_slot)
		hand_slot.rect_position.x = x
		hand_slot.rect_position.y = y
		#Add bottom slot
		hand_slot = HANDSLOT.instance()
		hand_slot.connect("reagent_set", self, "_on_reagent_set")
		slots.add_child(hand_slot)
		hand_slot.rect_position.x = x
		hand_slot.rect_position.y = y + hand_slot.rect_size.y
		
		#Update positions
		x = x + hand_slot.rect_size.x + H_SEPARATION

		# warning-ignore:integer_division
		if i < number/4:
			y = y + V_OFFSET
		# warning-ignore:integer_division
		elif i > number/4:
			y = y - V_OFFSET


func available_slot_count():
	var count = 0
	for slot in slots.get_children():
		if not slot.get_reagent():
			count += 1
	return count


#Places a reagent in an empty position, throws error if unable
func place_reagent(reagent):
	for slot in slots.get_children():
		if not slot.get_reagent():
			slot.set_reagent(reagent)
			yield(slot, "reagent_set")
			emit_signal("reagent_placed")
			return
	push_error("Can't place reagent in hand, hand is full.")
	assert(false)


func get_reagent_names() -> Array:
	var reagents := []
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			reagents.append(reagent.type)
		else:
			reagents.append(null)
	return reagents


func _on_reagent_set():
	emit_signal("hand_slot_reagent_set")
