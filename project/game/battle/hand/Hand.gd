tool
extends Node2D

signal reagent_placed
signal hand_slot_reagent_set
signal reagents_randomized

onready var slots = $Slots
onready var upper_slots = $Slots/UpperSlots
onready var lower_slots = $Slots/LowerSlots

const HANDSLOT = preload("res://game/battle/hand/HandSlot.tscn")

var size : int


func _draw():
	if not Engine.editor_hint:
		return
	
	draw_rect(Rect2(slots.rect_position, slots.rect_size), Color.red, false)
	draw_line(Vector2(slots.rect_size.x / 2, -10),
			Vector2(slots.rect_size.x / 2, slots.rect_size.y + 10), Color.red)
	draw_line(Vector2(-10, slots.rect_size.y / 2),
			Vector2(slots.rect_size.x + 10, slots.rect_size.y / 2), Color.red)


func get_width():
	return slots.rect_size.x


func get_height():
	return slots.rect_size.y


func get_slots():
	return upper_slots.get_children() + lower_slots.get_children()


func set_hand(number: int):
	size = number
	
	for slot in get_slots():
		slot.queue_free()
	
	for i in size:
		var handslot = HANDSLOT.instance()
		handslot.connect("reagent_set", self, "_on_reagent_set")
		# warning-ignore:integer_division
		if i < (number + 1) / 2:
			upper_slots.add_child(handslot)
		else:
			lower_slots.add_child(handslot)


func freeze_slots(amount: int):
	for slot in get_slots():
		if not slot.is_frozen():
			amount -= 1
			slot.freeze()
			AudioManager.play_sfx("freeze_slot")
			if amount <= 0:
				break

func unfreeze_all_slots():
	for slot in get_slots():
		if slot.is_frozen():
			slot.unfreeze()

func burn_reagents(amount : int):
	var reagents = []
	for slot in get_slots():
		var reagent = slot.get_reagent()
		if reagent and not reagent.is_burned():
			reagents.append(reagent)
	
# warning-ignore:narrowing_conversion
	amount = min(amount, reagents.size())
	randomize()
	reagents.shuffle()
	for i in range(0, amount):
		yield(get_tree().create_timer(rand_range(.04,.1)), "timeout")
		reagents[i].burn()

func unburn_reagents():
	for slot in get_slots():
		var reagent = slot.get_reagent()
		if reagent and reagent.is_burned():
			reagent.unburn()

func randomize_reagents():
	randomize()
	var should_emit = false
	for slot in get_slots():
		var reagent = slot.get_reagent()
		if reagent:
			should_emit = true
			AudioManager.play_sfx("randomize_reagent")
			ReagentManager.randomize_reagent(reagent)
			yield(get_tree().create_timer(rand_range(.05,.07)), "timeout")
	if should_emit:
		emit_signal("reagents_randomized")


func available_slot_count():
	var count = 0
	for slot in get_slots():
		if not slot.get_reagent() and not slot.is_frozen():
			count += 1
	return count


#Places a reagent in an empty position, throws error if unable
func place_reagent(reagent):
	for slot in get_slots():
		if not slot.get_reagent() and not slot.is_frozen():
			slot.set_reagent(reagent)
			yield(slot, "reagent_set")
			emit_signal("reagent_placed")
			return
	push_error("Can't place reagent in hand, hand is full.")
	assert(false)


func get_reagent_names() -> Array:
	var reagents := []
	for slot in get_slots():
		var reagent = slot.get_reagent()
		if reagent:
			reagents.append(reagent.type)
		else:
			reagents.append(null)
	return reagents


func _on_reagent_set():
	emit_signal("hand_slot_reagent_set")
