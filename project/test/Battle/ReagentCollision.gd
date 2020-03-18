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

