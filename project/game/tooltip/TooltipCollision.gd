extends Area2D

const TIMEOUT = .3

var timer = 0
var entered = false
var title = "TEssssst"
var text = "asdasdsdasdasdsd"
var pos

func set_shape(size: Vector2):
	$CollisionShape2D.shape.extents = size/2

func setup(_pos: Vector2, _title: String, _text: String):
	pos = _pos
	title = _title
	text = _text

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
			TooltipLayer.remove_tooltip(title)
			
func _process(delta):
	if entered and timer < TIMEOUT:
		timer += delta
		if timer >= TIMEOUT:
			timer = TIMEOUT
			TooltipLayer.add_tooltip(pos, title, text)
