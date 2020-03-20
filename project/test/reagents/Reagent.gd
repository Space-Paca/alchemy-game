extends Control

signal reached_target_pos

var is_drag = false
var can_drag = true
var drag_offset = Vector2(0,0)
var slot = null #current slot this reagent is in
onready var target_position = rect_position


func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_drag:
		rect_position = get_global_mouse_position() + drag_offset
	elif (not can_drag or not is_drag) and target_position:
		if rect_position.distance_to(target_position) > 0:
			rect_position += (target_position - rect_position)*.3
			if (target_position - rect_position).length() < 3:
				can_drag = true
				rect_position = target_position
				emit_signal("reached_target_pos")
