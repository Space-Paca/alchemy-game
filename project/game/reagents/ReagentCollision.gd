extends Area2D

onready var shape = $CollisionShape2D.shape
onready var reagent = get_parent()

var hovering = false

func _input(event):
	if event is InputEventMouseMotion and reagent.can_drag and not reagent.is_frozen():
		var mouse_pos = get_local_mouse_position()
		if reagent.hovering and not \
		   (mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y):
				reagent.stop_hovering()
		elif not reagent.hovering and \
			 (mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			  mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y):
				reagent.start_hovering()
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed and reagent.can_drag and not reagent.is_frozen():
			var mouse_pos = get_local_mouse_position()
			if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
				reagent.quick_place()
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed and reagent.can_drag and not reagent.is_frozen():
			var mouse_pos = get_local_mouse_position()
			if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
					reagent.start_dragging()
		elif not event.pressed and reagent.is_drag:
			var nearest_slot_area = null
			for area in get_overlapping_areas():
				if area.is_in_group("gridslot") or area.is_in_group("handslot"):
					if not nearest_slot_area:
						nearest_slot_area = area
					else:
						if self.global_position.distance_to(nearest_slot_area.global_position) > \
						   self.global_position.distance_to(area.global_position):
							nearest_slot_area = area
			if nearest_slot_area:
				var slot = nearest_slot_area.get_parent()
				if slot.type == "grid" and slot.is_restrained():
					reagent.unrestrain_slot(slot)
				elif not slot.get_reagent() and \
				   not (slot.type == "hand" and slot.is_frozen()) and \
				   not (slot.type == "grid" and slot.is_restricted()):
					slot.set_reagent(reagent)
					if self.global_position.distance_to(nearest_slot_area.global_position) > 0:
						reagent.can_drag = false
				elif not (slot.type == "hand" and slot.is_frozen()) and \
					 not (slot.type == "grid" and slot.is_restricted()):
					#In case there already was a reagent in that slot (and isn't frozen), switch places
					var other_reagent = slot.get_reagent()
					var previous_slot = reagent.slot
					other_reagent.slot = null
					slot.set_reagent(reagent)
					previous_slot.set_reagent(other_reagent)
					if self.global_position.distance_to(nearest_slot_area.global_position) > 0:
						reagent.can_drag = false
				else:
					AudioManager.play_sfx("error")
			reagent.drop_effect()
			reagent.stop_dragging()
			reagent.is_drag = false

