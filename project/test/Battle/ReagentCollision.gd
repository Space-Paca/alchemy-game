extends Area2D

onready var shape = $CollisionShape2D.shape


func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
		   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
			get_parent().can_drag = event.pressed

