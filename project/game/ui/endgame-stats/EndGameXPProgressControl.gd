extends Control

signal changed_xp

const MODIFIED_COLOR = Color.palegreen
const NORMAL_COLOR = Color.white

onready var stat_name = $Name
onready var current_xp_node = $NumberContainer/Current
onready var max_xp_node = $NumberContainer/Max
onready var slider = $HSlider
onready var allocated_label = $CurrentAllocatedXP

var available_xp = 10
var initial_xp = 20
var modified_xp = 0
var max_xp = 100


func _ready():
	#TEST
	setup("Unlock Recipes", 20, 100, 10)
	set_available_xp(5)


func setup(name, _initial_xp, _max_xp, total_available_xp):
	stat_name.text = name
	
	initial_xp = _initial_xp
	max_xp = _max_xp
	
	update_xp_text()
	
	available_xp = total_available_xp
	slider.max_value = total_available_xp


func set_available_xp(value):
	available_xp = value

func update_xp_text():
	current_xp_node.text = str(initial_xp + modified_xp)
	if modified_xp > 0:
		allocated_label.modulate = MODIFIED_COLOR
		current_xp_node.modulate = MODIFIED_COLOR
	else:
		allocated_label.modulate = NORMAL_COLOR
		current_xp_node.modulate = NORMAL_COLOR
	max_xp_node.text = "/"+str(max_xp)


func _on_HSlider_value_changed(value):
	if value > available_xp:
		var diff = value - available_xp
		slider.set_value(slider.value - diff)
		value = available_xp
	allocated_label.text = str(slider.value)
	var changed_value = value - modified_xp
	if changed_value != 0:
		modified_xp += changed_value
		update_xp_text()
		emit_signal("changed_xp", value)
