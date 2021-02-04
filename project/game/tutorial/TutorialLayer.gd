extends CanvasLayer

signal tutorial_finished

const ALPHA_SPEED = 2.5
const POS_SPEED = 6
const DIM_SPEED = 6
const MARGIN = 3
const DEFAULT_WIDTH = 400

onready var rect = $Rect
onready var label = $Label
onready var image = $Image

var active = false
var current_region = 0
var regions = []
var DB = load("res://game/tutorial/TutorialDB.gd").new()


func _ready():
	rect.modulate.a = 0
	label.modulate.a = 0


func _process(delta):
	if active:
		#BG alpha
		rect.modulate.a = min(rect.modulate.a + ALPHA_SPEED*delta, 1)
		
		var region = regions[current_region]
		var diff_sum = 0
		
		#Set hole position
		var pos = get_position()
		var target_pos = region.position
		var diff = (target_pos - pos)
		if diff.length() <= POS_SPEED*delta:
			pos = target_pos
		else:
			pos += diff*min(POS_SPEED*delta,1)
		set_position(pos)
		diff_sum += diff.length()
		
		#Set hole size
		var dimension = get_dimension()
		var target_dim = region.dimension
		diff = (target_dim - dimension)
		if diff.length() <= DIM_SPEED*delta:
			dimension = target_dim
		else:
			dimension += diff*min(DIM_SPEED*delta,1)
		set_dimension(dimension)
		diff_sum += diff.length()
		
		label.modulate.a = (1.0 - min(diff_sum/10, 1))*rect.modulate.a
		image.modulate.a = label.modulate.a
	else:
		#BG alpha
		rect.modulate.a = max(rect.modulate.a - ALPHA_SPEED*delta, 0)
		label.modulate.a = rect.modulate.a
		image.modulate.a = rect.modulate.a


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if active:
			current_region += 1
			if current_region >= regions.size():
				active = false
				regions = null
				current_region = false
				emit_signal("tutorial_finished")
				yield(get_tree(), "idle_frame")
				rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			else:
				update_elements()


func is_active():
	return active


func start(name):
	set_regions(DB.get(name))


func set_regions(new_regions):
	current_region = 0
	regions = new_regions
	set_position(regions[0].position + regions[0].dimension/2)
	set_dimension(Vector2(0,0))
	update_elements()
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	active = true


func set_position(position):
	rect.material.set_shader_param("position", position)


func set_dimension(dimension):
	rect.material.set_shader_param("dimension", dimension)


func get_position():
	return rect.material.get_shader_param("position")


func get_dimension():
	return rect.material.get_shader_param("dimension")


func update_elements():
	#Start with label
	label.text = ""
	label.rect_size.y = 1
	var region = regions[current_region]
	label.text = region.text
	if region.has("text_width"):
		label.rect_size.x = region.text_width
	else:
		label.rect_size.x = DEFAULT_WIDTH
	yield(get_tree(), "idle_frame")
	
	#Set tutorial text position
	if region.text_side == "left":
		label.rect_position.x = region.position.x - label.rect_size.x - MARGIN
		label.rect_position.y = region.position.y + region.dimension.y/2 - label.rect_size.y/2
		label.valign = Label.VALIGN_CENTER
	elif region.text_side == "right":
		label.rect_position.x = region.position.x + region.dimension.x + MARGIN
		label.rect_position.y = region.position.y + region.dimension.y/2 - label.rect_size.y/2
		label.valign = Label.VALIGN_CENTER
	elif region.text_side == "top":
		label.rect_position.x = region.position.x + region.dimension.x/2 - label.rect_size.x/2
		label.rect_position.y = region.position.y - label.rect_size.y - MARGIN
		label.valign = Label.VALIGN_TOP
	elif region.text_side == "bottom":
		label.rect_position.x = region.position.x + region.dimension.x/2 - label.rect_size.x/2
		label.rect_position.y = region.position.y + region.dimension.y + MARGIN
		label.valign = Label.VALIGN_TOP
	
	#Now image
	update_image()
	
func update_image():
	var region = regions[current_region]
	if region.has("image"):
		image.show()
		image.texture = load(region.image)
		if region.has("image_scale"):
			image.rect_scale = Vector2(region.image_scale, region.image_scale)
		else:
			image.rect_scale = Vector2(1,1)
		
		var w = image.texture.get_width()*region.image_scale
		var h = image.texture.get_height()*region.image_scale
		
		#Set tutorial image position
		if region.text_side == "left":
			image.rect_position.x = label.rect_position.x - MARGIN - w
			image.rect_position.y = region.position.y + region.dimension.y/2 - h/2
		elif region.text_side == "right":
			image.rect_position.x = label.rect_position.x + label.rect_size.x + MARGIN
			image.rect_position.y = region.position.y + region.dimension.y/2 - h/2
		elif region.text_side == "top":
			image.rect_position.x = region.position.x + region.dimension.x/2 - w/2
			image.rect_position.y = label.rect_position.y - MARGIN - h
		elif region.text_side == "bottom":
			image.rect_position.x = region.position.x + region.dimension.x/2 - w/2
			image.rect_position.y = label.rect_position.y + label.rect_size.y + MARGIN
	else:
		image.hide()
