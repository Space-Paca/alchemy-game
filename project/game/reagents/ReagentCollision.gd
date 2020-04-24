extends Area2D

onready var shape = $CollisionShape2D.shape
onready var reagent = get_parent()

var hovering = false

func _input(event):
	if event is InputEventMouseMotion and reagent.can_drag:
		var mouse_pos = get_local_mouse_position()
		if hovering and not \
		   (mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y):
				reagent.stop_hover_effect()
				hovering = false
		elif not hovering and \
			 (mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			  mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y):
				reagent.hover_effect()
				hovering  = true
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed and reagent.can_drag:
			var mouse_pos = get_local_mouse_position()
			if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
			   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
					reagent.pick_effect()
					reagent.is_drag = true
					reagent.drag_offset = -get_local_mouse_position()
					reagent.start_dragging()
		elif not event.pressed and reagent.is_drag:
			reagent.drop_effect()
			reagent.is_drag = false
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
				if not slot.get_reagent():
					slot.set_reagent(reagent)
					if self.global_position.distance_to(nearest_slot_area.global_position) > 0:
						reagent.can_drag = false
				else:
					#In case there alraedy was a reagent in that slot, switch places
					var other_reagent = slot.get_reagent()
					var previous_slot = reagent.slot
					other_reagent.slot = null
					slot.set_reagent(reagent)
					previous_slot.set_reagent(other_reagent)
					if self.global_position.distance_to(nearest_slot_area.global_position) > 0:
						reagent.can_drag = false

