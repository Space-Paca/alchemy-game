extends Control

signal changed_xp
signal finished_applying

const MODIFIED_COLOR = Color.aqua
const NORMAL_COLOR = Color.white
const PREVIEW_DUR = .3

onready var stat_name = $Name
onready var current_xp_node = $NumberContainer/Current
onready var max_xp_node = $NumberContainer/Max
onready var slider = $HSlider
onready var allocated_label = $CurrentAllocatedXP
onready var preview = $PreviewProgress
onready var progress_bar = $StatProgress


var ignore_callback = false
var available_xp = 10
var initial_xp = 20
var modified_xp = 0
var max_xp = 100


func _ready():
	reset_preview()


func apply():
	slider.editable = false
	
	progress_bar.value += modified_xp
	var dur = 1.2
	var target_rect = Rect2(0, 0, 0, progress_bar.rect_size.y)
	var target_percentage = ((initial_xp + modified_xp)/float(max_xp))
	var target_x = target_percentage*progress_bar.rect_size.x
	
	initial_xp += modified_xp 
	modified_xp = 0
	
	ignore_callback = true
	$Tween.interpolate_method(self, "set_slider_value", slider.value, 0, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(preview, "region_rect", preview.region_rect, target_rect, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(preview, "position:x", preview.position.x, target_x, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	ignore_callback = false
	slider.editable = true
	emit_signal("finished_applying")

func get_modified_xp():
	return modified_xp


func set_total_available_xp(value):
	available_xp = value
	slider.max_value = value

func setup(name, _initial_xp, _max_xp, total_available_xp):
	stat_name.text = name
	
	initial_xp = _initial_xp
	max_xp = _max_xp
	
	update_xp_text()
	
	available_xp = total_available_xp
	slider.max_value = total_available_xp
	progress_bar.max_value = max_xp
	progress_bar.value = initial_xp
	
	reset_preview()


func set_available_xp(value):
	available_xp = value


func reset_preview():
	#Set proper scale so effect bar is the same size as progress bar
	preview.scale.x = progress_bar.rect_size.x/float(preview.texture.get_width())
	preview.scale.y = progress_bar.rect_size.y/float(preview.texture.get_height())
	preview.position.x = progress_bar.rect_position.x + progress_bar.rect_size.x/2
	preview.position.y = progress_bar.rect_position.y + progress_bar.rect_size.y/2
	
	var cur_xp_percentage = (initial_xp/float(max_xp))
	var y = progress_bar.rect_position.y + progress_bar.rect_size.y/2
	preview.region_rect = Rect2(0, 0, 0, progress_bar.rect_size.y)
	preview.position = Vector2(cur_xp_percentage*progress_bar.rect_size.x, y)

func update_preview():
	var cur_xp_percentage = (initial_xp/float(max_xp))
	var gain_percent = (modified_xp / float(max_xp))
	
	#Calculate what region of the texture to cut
	var w = gain_percent * progress_bar.rect_size.x/preview.scale.x
	var h = progress_bar.rect_size.y
	var target_rect = Rect2(0, 0, w, h)
	
	#Since it is a sprite, position pivot is in the middle
	var y = progress_bar.rect_position.y + progress_bar.rect_size.y/2
	var target_pos = Vector2((cur_xp_percentage + gain_percent/2)*progress_bar.rect_size.x, y)
	
	#Stretch effect
	$Tween.remove_all()
	var dur = PREVIEW_DUR
	$Tween.interpolate_property(preview, "region_rect", preview.region_rect, target_rect, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(preview, "position", preview.position, target_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


func update_xp_text():
	current_xp_node.text = str(initial_xp + modified_xp)
	if modified_xp > 0:
		current_xp_node.modulate = MODIFIED_COLOR
	else:
		current_xp_node.modulate = NORMAL_COLOR
	max_xp_node.text = "/"+str(max_xp)


func set_slider_value(value):
	slider.set_value(value)
	allocated_label.text = str(slider.value)
	if slider.value == 0:
		allocated_label.modulate = NORMAL_COLOR
	else:
		allocated_label.modulate = MODIFIED_COLOR


func _on_HSlider_value_changed(value):
	if ignore_callback:
		return
	var changed_value = value - modified_xp
	if changed_value > available_xp:
		value = modified_xp + available_xp
	if initial_xp + value > max_xp:
		value = max_xp - initial_xp
	set_slider_value(value)
	changed_value = value - modified_xp
	if changed_value != 0:
		modified_xp += changed_value
		update_xp_text()
		update_preview()
		emit_signal("changed_xp", changed_value)