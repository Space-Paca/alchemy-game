extends Control

var type = "reagent"

var can_drag = false

func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_drag:
		rect_position = get_global_mouse_position()
