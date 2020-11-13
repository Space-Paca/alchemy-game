extends Control

signal filters_updated(values)

onready var filter_rect = $Filters
onready var filters = $Filters/VBoxContainer.get_children()

var filter_values := []


func reapply_filters():
	emit_signal("filters_updated", filter_values)


func clear_filters():
	for filter in filters:
		filter.pressed = false
	
	filter_values.clear()
	
	emit_signal("filters_updated", filter_values)


func _on_Button_toggled(button_pressed: bool):
	filter_rect.visible = button_pressed


func _on_Filter_toggled(button_pressed: bool, index: int):
	if button_pressed:
		filter_values.append(index)
	else:
		filter_values.erase(index)
	
	emit_signal("filters_updated", filter_values)
