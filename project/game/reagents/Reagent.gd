extends Control

signal reached_target_pos

onready var texture_rect = $TextureRect

var is_drag = false
var can_drag = true
var disable_drag = false
var drag_offset = Vector2(0,0)
var slot = null # current slot this reagent is in
var target_position = rect_position
var type = "none"
var image_path : String

func _ready():
	texture_rect.texture = load(image_path)

func enable_dragging():
	can_drag = true
	disable_drag = false

func disable_dragging():
	can_drag = false
	disable_drag = true

func _process(_delta):
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_drag = false
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_drag:
		rect_position = get_global_mouse_position() + drag_offset
	elif not is_drag and target_position:
		if rect_position.distance_to(target_position) > 0:
			rect_position += (target_position - rect_position)*.3
			if (target_position - rect_position).length() < 3:
				if not disable_drag:
					can_drag = true
				rect_position = target_position
				emit_signal("reached_target_pos")
