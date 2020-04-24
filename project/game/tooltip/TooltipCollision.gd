extends Area2D

const TIMEOUT = .3

signal enable_tooltip
signal disable_tooltip

var timer = 0
var entered = false

func set_shape(size: Vector2):
	$CollisionShape2D.shape.extents = size/2

func _input(event):
	var shape = $CollisionShape2D.shape
	if event is InputEventMouseMotion:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x >= -shape.extents.x and mouse_pos.x <= shape.extents.x and \
		   mouse_pos.y >= -shape.extents.y and mouse_pos.y <= shape.extents.y:
			if not entered:
				entered = true
		elif entered:
			entered = false
			timer = 0
			emit_signal("disable_tooltip")
			
func _process(delta):
	if entered and timer < TIMEOUT:
		timer += delta
		if timer >= TIMEOUT:
			timer = TIMEOUT
			emit_signal("enable_tooltip")