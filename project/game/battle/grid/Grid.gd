tool
extends Control

signal cleaned
signal modified
signal returned_to_hand
signal reagent_destroyed
signal dispensed_reagents
signal repositioned_reagents
signal restrained

const GRIDSLOT = preload("res://game/battle/grid/GridSlot.tscn")
const SEPARATION = 4

onready var container = $CenterContainer
onready var slots = $CenterContainer/GridContainer

var discard_bag = null # Set by parent
var hand = null # Set by parent
var grid_size : int


func _draw():
	if not Engine.editor_hint:
		return
	
	draw_rect(Rect2(Vector2.ZERO, container.rect_size), Color.green, false)
	draw_line(Vector2(container.rect_size.x/2, -10),
			Vector2(container.rect_size.x/2, container.rect_size.y+10), Color.green)
	draw_line(Vector2(-10, container.rect_size.y/2),
			Vector2(container.rect_size.x+10, container.rect_size.y/2), Color.green)


func get_data():
	var data = []
	for slot in slots.get_children():
		var slot_data = {
			"restricted": slot.restricted,
			"restrained": slot.restrained,
		}
		data.append(slot_data)

	return data


func load_data(data : Array):
	for i in slots.get_child_count():
		var slot = slots.get_child(i)
		var slot_data = data[i]
		if slot_data.restrained:
			slot.restrain()
		if slot_data.restricted:
			slot.restrict()


func get_center():
	return container.rect_global_position + container.rect_size/2


func get_width():
	assert(slots.get_child_count() > 0)
	var slot = slots.get_child(0)
	return grid_size*slot.rect_size.x + (grid_size-1)*SEPARATION


func get_height():
	assert(slots.get_child_count() > 0)
	var slot = slots.get_child(0)
	return grid_size * slot.rect_size.y + (grid_size-1)*SEPARATION


func highlight_blocked_slots():
	for slot in slots.get_children():
		if slot.is_restrained() or slot.is_restricted():
			slot.block_highlight_effect()


func set_grid(_size: int):
	assert(_size > 1)
	grid_size = _size
	for child in slots.get_children():
		slots.remove_child(child)
	
	slots.columns = grid_size
	
	for _i in grid_size:
		for _j in grid_size:
			var slot = GRIDSLOT.instance()
			slots.add_child(slot)
			slot.connect("reagent_set", self, "_on_slot_changed")
			slot.connect("reagent_removed", self, "_on_slot_changed")


func hide_effects():
	for slot in slots.get_children():
		slot.hide_effects()


func show_effects():
	for slot in slots.get_children():
		slot.show_effects()


func is_empty():
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			return false
	return true

func is_full():
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if not reagent:
			return false
	return true

func quick_place(reagent):
	#Search for available hint first
	for slot in slots.get_children():
		if not slot.get_reagent() and slot.get_hint() == reagent.type:
			AudioManager.play_sfx("quick_place_grid")
			slot.set_reagent(reagent)
			return

	#Then search for substitutes the reagent may have
	var data = ReagentManager.get_data(reagent.type)
	for sub_reagent in data.substitute:
		for slot in slots.get_children():
			if not slot.get_reagent() and slot.get_hint() == sub_reagent:
				AudioManager.play_sfx("quick_place_grid")
				slot.set_reagent(reagent)
				return

	#Then search for unknown hints on the grid
	for slot in slots.get_children():
		if not slot.get_reagent() and slot.get_hint() == "unknown":
			AudioManager.play_sfx("quick_place_grid")
			slot.set_reagent(reagent)
			return

	#Finally search for empty space after
	for slot in slots.get_children():
		if not slot.get_reagent() and not slot.is_restrained() and not slot.is_restricted():
			AudioManager.play_sfx("quick_place_grid")
			slot.set_reagent(reagent)
			return
	#If got here, don't have an available space
	AudioManager.play_sfx("error")

func destroy_reagent(reagent_type):
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent and reagent.type == reagent_type:
			slot.remove_reagent()
			reagent.destroy()
			yield(reagent, "destroyed")
			emit_signal("reagent_destroyed")
			return true

	return false

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

func dispense_reagents():
	var reagents_to_be_dispensed = []
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_dispensed.append(reagent)
	
	randomize()
	while not reagents_to_be_dispensed.empty():
		var reagent = reagents_to_be_dispensed.pop_back()
		AudioManager.play_sfx("discard_reagent")
		reagent.return_to_dispenser()
		yield(get_tree().create_timer(rand_range(.05, .1)), "timeout")

	emit_signal("dispensed_reagents")

func reposition_reagents():
	randomize()
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			reagent.reset_to_gridslot(slot)
			yield(get_tree().create_timer(rand_range(.05, .1)), "timeout")

	emit_signal("repositioned_reagents")

func clean():
	var reagents_to_be_discarded = []
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_discarded.append(reagent)

	randomize()
	while not reagents_to_be_discarded.empty():
		var reagent = reagents_to_be_discarded.pop_back()
		AudioManager.play_sfx("discard_reagent")
		discard_bag.discard(reagent)
		if not reagents_to_be_discarded.empty():
			yield(get_tree().create_timer(rand_range(.05, .1)), "timeout")
		else:
			yield(discard_bag, "reagent_discarded")

	emit_signal("cleaned")


func remove_reagent(target_reagent):
	for slot in slots.get_children():
		var reagent = slot.get_reagent()
		if reagent == target_reagent:
			slot.remove_reagent()
			AudioManager.play_sfx("discard_reagent")
			discard_bag.discard(reagent)


func show_combination_hint(combination: Combination):
	for off_i in range(0, grid_size - combination.grid_size + 1):
		for off_j in range(0, grid_size - combination.grid_size + 1):
			
			var valid_hint = true
			for i in range(combination.grid_size):
				for j in range(combination.grid_size):
					var slot = slots.get_child((i+off_i) * grid_size + (j+off_j))
					if combination.matrix[i][j] and (slot.is_restrained() or slot.is_restricted()):
						valid_hint = false
						clear_hints()
						break
					else:
						if not combination.discovered:
							slot.set_hint(combination.known_matrix[i][j])
						else:
							slot.set_hint(combination.matrix[i][j])
				if not valid_hint:
					break
			if valid_hint:
				return true
	return false


func clear_hints():
	for slot in slots.get_children():
		slot.set_hint(null)

func restrict(amount: int, type: String):
	var unrestricted_slots = []
	
	#Get only edge slots
	if type == "minor":
		for i in range(0,grid_size):
			for j in range(0,grid_size):
				if i == 0 or i == grid_size -1 or \
				   j == 0 or j == grid_size -1:
					var slot = slots.get_child(i + j*grid_size)
					if not slot.is_restricted():
						unrestricted_slots.append(slot)
	#Get only central slots
	elif type == "major":
		for i in range(0,grid_size):
			for j in range(0,grid_size):
				if i != 0 and i != grid_size -1 and \
				   j != 0 and j != grid_size -1:
					var slot = slots.get_child(i + j*grid_size)
					if not slot.is_restricted():
						unrestricted_slots.append(slot)
	else:
		assert(false, "Not a valid type of restriction: " + str(type))
	
	while amount > 0 and unrestricted_slots.size() > 0:
			randomize()
			unrestricted_slots.shuffle()
			var slot = unrestricted_slots.pop_front()
			slot.restrict()
			amount -= 1

func unrestrict_all_slots():
	for slot in slots.get_children():
		if slot.is_restricted():
			slot.unrestrict()

func restrain(amount : int):
	var restrain_slots = []
	for slot in slots.get_children():
		if not slot.is_restrained():
			restrain_slots.append(slot)
	
	var emit = amount > 0 and not restrain_slots.empty()
	
	randomize()
	restrain_slots.shuffle()
	while amount > 0 and not restrain_slots.empty():
		var slot = restrain_slots.pop_front()
		slot.restrain()
		amount -= 1
		yield(get_tree().create_timer(.1), "timeout")
	
	if emit:
		emit_signal("restrained")

func unrestrain_all_slots():
	for slot in slots.get_children():
		if slot.is_restrained():
			slot.unrestrain()

func _on_slot_changed():
	print("Slot changed")
	emit_signal("modified")
