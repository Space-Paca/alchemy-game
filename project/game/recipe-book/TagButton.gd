extends TextureButton

onready var label = $Label
onready var label_original_x = label.rect_position.x

const ACTIVE_OFFSET = 30

export(float) var max_offset = 30
export(float) var lerp_weight = .2

var is_active := false
var is_mouse_inside := false
var offset := 0


func _ready():
# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_mouse_entered")
# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "_on_mouse_exited")


func _process(_delta):
	var target = max_offset if is_mouse_inside else 0
	if offset != target:
		offset = lerp(offset, target, lerp_weight)
		offset_position(offset)
	else:
		set_process(false)


func offset_position(o: float):
	material.set_shader_param("offset", o)
	label.rect_position.x = label_original_x + o


func reset_offset():
	set_process(false)
	is_mouse_inside = false
	offset = 0
	offset_position(0)


func set_active(active: bool):
	if active == is_active:
		return
	
	is_active = active
	label_original_x += ACTIVE_OFFSET * (1 if active else -1)
	label.rect_position.x = label_original_x + offset


func _on_mouse_entered():
	AudioManager.play_sfx("hover_button")
	is_mouse_inside = true
	set_process(true)


func _on_mouse_exited():
	is_mouse_inside = false
	set_process(true)
