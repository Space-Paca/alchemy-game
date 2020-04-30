tool
extends Control

signal cleaned
signal returned_to_hand

const GRIDSLOT = preload("res://game/battle/grid/GridSlot.tscn")
const MARGIN = 380

onready var container = $GridContainer

var discard_bag = null # Set by parent
var hand = null # Set by parent
var grid_size : int


func _ready():
	set_grid(4)

func get_center():
	return rect_global_position + Vector2(get_width()*rect_scale.x/2, \
										  get_height()*rect_scale.y/2)

func get_width():
	var slot = container.get_child(1)
	return grid_size * slot.rect_size.x


func get_height():
	var slot = container.get_child(1)
	return grid_size * slot.rect_size.y


func set_grid(_size: int):
	assert(_size > 1)
	grid_size = _size
	for child in container.get_children():
		container.remove_child(child)
	container.columns = grid_size
	for _i in range(grid_size * grid_size):
		container.add_child(GRIDSLOT.instance())


func is_empty():
	for slot in container.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			return false
	return true


func return_to_hand():
	var reagents_to_be_sent = []
	for slot in container.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_sent.append(reagent)
	
	while not reagents_to_be_sent.empty():
		var reagent = reagents_to_be_sent.pop_back()
		hand.place_reagent(reagent)
		if not reagents_to_be_sent.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.05, .1)), "timeout")
		else:
			yield(hand, "reagent_placed")
	
	emit_signal("returned_to_hand")


func clean():
	var reagents_to_be_discarded = []
	for slot in container.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_discarded.append(reagent)
	
	while not reagents_to_be_discarded.empty():
		var reagent = reagents_to_be_discarded.pop_back()
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
			var slot = container.get_child(i * grid_size + j)
			slot.set_hint(combination.matrix[i][j])


func clear_hint():
	for slot in container.get_children():
		slot.set_hint(null)
