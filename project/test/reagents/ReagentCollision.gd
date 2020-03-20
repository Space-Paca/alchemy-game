extends Area2D

onready var shape = $CollisionShape2D.shape
onready var reagent = get_parent()

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
		   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
			if reagent.can_drag:
				reagent.is_drag = event.pressed
			if reagent.is_drag:
				reagent.drag_offset = -get_local_mouse_position()
			else:
				reagent.can_drag = false #Disable dragging until reagent returns to target position
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

