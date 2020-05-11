tool
extends Control

signal cleaned
signal returned_to_hand

const GRIDSLOT = preload("res://game/battle/grid/GridSlot.tscn")
const SEPARATION = 4

onready var slots = $Slots

var discard_bag = null # Set by parent
var hand = null # Set by parent
var grid_size : int


func _ready():
	set_grid(4)

func get_center():
	return rect_global_position

func get_width():
	assert(slots.get_child_count() > 0)
	var slot = slots.get_child(0)
	return grid_size*slot.rect_size.x + (grid_size-1)*SEPARATION

func get_height():
	assert(slots.get_child_count() > 0)
	var slot = slots.get_child(0)
	return grid_size * slot.rect_size.y + (grid_size-1)*SEPARATION


func set_grid(_size: int):
	assert(_size > 1)
	grid_size = _size
	for child in slots.get_children():
		slots.remove_child(child)
	
	var temp_slot = GRIDSLOT.instance()
	var sw = temp_slot.get_width()
	var sh = temp_slot.get_height()
	var y = -(grid_size * sh + (grid_size-1)*SEPARATION)/2
	for i in range(grid_size):
		var x = -(grid_size * sw + (grid_size-1)*SEPARATION)/2
		for j in range(grid_size):
			var slot = GRIDSLOT.instance()
			slot.rect_position.x = x
			slot.rect_position.y = y
			
			if grid_size > 2:
				#Top-left slot
				var v = SEPARATION - 1
				if i == 0 and j == 0:
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					slot.rect_position += Vector2(v, v)
				#Top-right slot
				elif i == 0 and j == grid_size-1:
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					slot.rect_position += Vector2(-v, v)
				#Bottom-left slot
				elif i == grid_size-1 and j == 0:
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					slot.rect_position += Vector2(v, -v)
				#Bottom-right slot
				elif i == grid_size-1 and j == grid_size-1:
					# warning-ignore:integer_division
					# warning-ignore:integer_division
					slot.rect_position += Vector2(-v, -v)
				
			slots.add_child(slot)
			x += sw + SEPARATION
		y += sh + SEPARATION


func is_empty():
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			return false
	return true


func return_to_hand():
	var reagents_to_be_sent = []
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_sent.append(reagent)
	
	while not reagents_to_be_sent.empty():
		var reagent = reagents_to_be_sent.pop_back()
		hand.place_reagent(reagent)
		if not reagents_to_be_sent.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.05, .13)), "timeout")
		else:
			yield(hand, "reagent_placed")
	
	emit_signal("returned_to_hand")


func clean():
	var reagents_to_be_discarded = []
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_discarded.append(reagent)

	#if not reagents_to_be_discarded.empty():
	#	AudioManager.play_sfx("discard_reagent")
	while not reagents_to_be_discarded.empty():
		var reagent = reagents_to_be_discarded.pop_back()
		AudioManager.play_sfx("discard_reagent")
		discard_bag.discard(reagent)
		if not reagents_to_be_discarded.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.05, .1)), "timeout")
		else:
			yield(discard_bag, "reagent_discarded")

	emit_signal("cleaned")


func show_combination_hint(combination: Combination):
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			var slot = slots.get_child(i * grid_size + j)
			slot.set_hint(combination.matrix[i][j])


func clear_hint():
	for slot in slots.get_children():
		slot.set_hint(null)
