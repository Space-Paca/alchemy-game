extends Control

signal changed_xp

onready var stat_name = $Name
onready var current_xp_node = $NumberContainer/Current
onready var max_xp_node = $NumberContainer/Max
onready var slider = $HSlider
onready var allocated_label = $CurrentAllocatedXP

var available_xp = 10
var initial_xp = 20
var modified_xp = 0
var max_xp = 100
var previous_value #USE THIS


func setup(name, _initial_xp, _max_xp, total_available_xp):
	stat_name.text = name
	
	initial_xp = _initial_xp
	max_xp = _max_xp
	
	update_xp_text()
	
	available_xp = total_available_xp
	slider.max_value = total_available_xp


func update_xp_text():
	current_xp_node.text = str(initial_xp + modified_xp)
	if modified_xp > 0:
		current_xp_node.modulate = Color.blue
	else:
		current_xp_node.modulate = Color.white
	max_xp_node.text = "/"+str(max_xp)


func _on_HSlider_value_changed(value):
	if value > available_xp:
		slider.value -= value - available_xp
		value = value - available_xp
		
	allocated_label.text = str(slider.value)
	if value != 0:
		modified_xp += value
		update_xp_text()
		emit_signal("changed_xp", value)
