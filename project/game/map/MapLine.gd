extends Node2D
class_name MapLine

signal filled


const LIGHT_TEX = preload("res://assets/images/map/light_tex.png")
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
	for i in ball_amount:
		var light = $Lights.get_child(i)
		light.mode = Light2D.MODE_ADD
		var dur = PATH_FILL_TIME/float(ball_amount)
		$Tween.interpolate_property(light, "energy", 0.01, .3, dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
		yield(get_tree().create_timer(dur), "timeout")
		light.mode = Light2D.MODE_MIX
		light.energy = 1

func set_line(origin:Vector2, target:Vector2):
	var dist := origin.distance_to(target) - MAP_NODE_SIZE
	line_vector = target - origin
	ball_amount = int(dist / BALL_DIST) + 1
	dist -= (ball_amount - 1) * BALL_DIST
	position = origin + line_vector.clamped((MAP_NODE_SIZE + dist) / 2)
	randomize()
	for i in ball_amount:
		balls.append(IMAGES[randi() % IMAGES.size()])
		var light = Light2D.new()
		light.texture = LIGHT_TEX
		light.mode = Light2D.MODE_MIX
		light.texture_scale = rand_range(.5, .8)
		light.rotation = rand_range(0, 360)
		light.position = line_vector.clamped(i * BALL_DIST)
		light.energy = 0
		light.range_item_cull_mask = 16 #bit 4
		$Lights.add_child(light)
		


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
