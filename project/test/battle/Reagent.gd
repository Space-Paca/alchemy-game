extends Control

var is_drag = false
var drag_offset = Vector2(0,0)
onready var target_position = rect_position

func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_drag:
		rect_position = get_global_mouse_position() + drag_offset
	elif not is_drag and target_position:
		rect_position += (target_position - rect_position)*.3
		if (target_position - rect_position).length() < 3:
			rect_position = target_position
