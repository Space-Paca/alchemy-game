extends Control

var type = "reagent"

var can_drag = false
var drag_offset = Vector2(0,0)

func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_drag:
		rect_position = get_global_mouse_position() + drag_offset
