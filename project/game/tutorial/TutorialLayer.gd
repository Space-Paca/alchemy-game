extends CanvasLayer

const ALPHA_SPEED = 2.5
const POS_SPEED = 600
const DIM_SPEED = 600

onready var rect = $Rect

var active = false
var current_region = 0
var regions = []
var DB = load("res://game/tutorial/TutorialDB.gd").new()


func _ready():
	rect.modulate.a = 0


func _process(delta):
	if active:
		rect.modulate.a = min(rect.modulate.a + ALPHA_SPEED*delta, 1)
		var pos = get_position()
		var target_pos = regions[current_region].position
		var diff = (target_pos - pos)
		if diff.length() <= POS_SPEED*delta:
			pos = target_pos
		else:
			pos += diff.normalized()*POS_SPEED*delta
		set_position(pos)
		var dimension = get_dimension()
		var target_dim = regions[current_region].dimension
		diff = (target_dim - dimension)
		if diff.length() <= DIM_SPEED*delta:
			dimension = target_dim
		else:
			dimension += diff.normalized()*DIM_SPEED*delta
		set_dimension(dimension)
	else:
		rect.modulate.a = max(rect.modulate.a - ALPHA_SPEED*delta, 0)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if active:
			current_region += 1
			if current_region >= regions.size():
				active = false
				regions = null
				current_region = false

func start(name):
	set_regions(DB.get(name))

func set_regions(new_regions):
	current_region = 0
	regions = new_regions
	set_position(regions[0].position + regions[0].dimension/2)
	set_dimension(Vector2(0,0))
	active = true


func set_position(position):
	rect.material.set_shader_param("position", position)


func set_dimension(dimension):
	rect.material.set_shader_param("dimension", dimension)


func get_position():
	return rect.material.get_shader_param("position")


func get_dimension():
	return rect.material.get_shader_param("dimension")
