tool
extends Control

signal cleaned
signal create_pressed(reagent_matrix)

const GRIDSLOT = preload("res://game/battle/grid/GridSlot.tscn")
const MARGIN = 30

onready var container = $GridContainer
onready var create_button = $CreateButton 

var discard_bag = null # Set by parent
var size : int

func get_width():
	var slot = container.get_child(1)
	return size * slot.rect_size.x

func set_grid(_size: int):
	assert(_size > 1)
	size = _size
	for child in container.get_children():
		container.remove_child(child)
	container.columns = size
	for _i in range(size * size):
		container.add_child(GRIDSLOT.instance())
	var slot = container.get_child(1)
	
	#Position button correctly
	var scale = create_button.rect_scale.x
	create_button.rect_position.y = slot.rect_size.y * size + MARGIN
	create_button.rect_position.x = slot.rect_size.x*size/2 - create_button.rect_size.x*scale/2


func is_empty():
	for slot in container.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			return false
	return true


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
			yield(get_tree().create_timer(rand_range(.1, .3)), "timeout")
		else:
			yield(discard_bag, "reagent_discarded")

	emit_signal("cleaned")


func disable():
	create_button.disabled = true


func enable():
	create_button.disabled = false


func _on_CreateButton_pressed():
	if is_empty():
		return
	
	var reagent_matrix := []
	var child_index := 0
	for _i in range(size):
		var line = []
		for _j in range(size):
			var reagent = container.get_child(child_index).current_reagent
			if reagent:
				line.append(reagent.type)
			else:
				line.append(null)
			child_index += 1
		reagent_matrix.append(line)
	
	emit_signal("create_pressed", reagent_matrix)
