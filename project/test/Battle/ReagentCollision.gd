extends Area2D

onready var shape = $CollisionShape2D.shape
onready var reagent = get_parent()

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
		   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
			reagent.is_drag = event.pressed
			if reagent.is_drag:
				reagent.drag_offset = -get_local_mouse_position()
			else:
				var nearest_slot = null
				for area in get_overlapping_areas():
					if area.is_in_group("gridslot"):
						if not nearest_slot:
							
							nearest_slot = area
						else:
							if self.global_position.distance_to(nearest_slot.global_position) > \
							   self.global_position.distance_to(area.global_position):
								nearest_slot = area
				if nearest_slot:
					reagent.target_position = nearest_slot.global_position

