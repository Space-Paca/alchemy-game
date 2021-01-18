extends Node2D
class_name MapLine

signal filled

const BALL_COLOR = Color.black
const BALL_DIST = 30
const BALL_SIZE = Vector2(10, 10)
const MAP_NODE_SIZE = 64
const PATH_FILL_TIME = 1
const WAIT_TIMER = .1
const IMAGES = [preload("res://assets/images/map/path-map-1.png"),
	preload("res://assets/images/map/path-map-2.png"),
	preload("res://assets/images/map/path-map-3.png")]

var ball_amount : int
var balls := []
var line_vector : Vector2
var time := 0.0


func _ready():
	set_process(false)


func begin_fill():
	set_process(true)


func set_line(origin:Vector2, target:Vector2):
	var dist := origin.distance_to(target) - MAP_NODE_SIZE
	line_vector = target - origin
	ball_amount = int(dist / BALL_DIST) + 1
	dist -= (ball_amount - 1) * BALL_DIST
	position = origin + line_vector.clamped((MAP_NODE_SIZE + dist) / 2)
	for i in ball_amount:
		balls.append(IMAGES[randi() % IMAGES.size()])


func _process(delta):
	time += delta
	update()
	if time >= PATH_FILL_TIME:
		set_process(false)
		yield(get_tree().create_timer(WAIT_TIMER), "timeout")
		emit_signal("filled")


func _draw():
	for i in ball_amount:
		var pos := line_vector.clamped(i * BALL_DIST)
		var radius_multiplier = ball_amount * time / PATH_FILL_TIME - i
		radius_multiplier = clamp(radius_multiplier, 0, 1)
		var size = BALL_SIZE * radius_multiplier
		draw_texture_rect(balls[i], Rect2(pos - size / 2, size), false)
