extends Label

signal animation_finished

export var unit := "EP"
export var min_duration_point := .03
export var max_duration := .7
export var color := Color.rebeccapurple

var amount := 0
var should_skip := false
var animation_active := false
var t : Tween

func _ready():
	text = "0" + " " + tr(unit)
	set("custom_colors/font_color", color)


func animate(s := false):
	animation_active = true
	should_skip = s
	if should_skip:
		change_text_value(amount)
	else:
		t = Tween.new()
		add_child(t)
		var duration = min(max_duration, min_duration_point * amount)
# warning-ignore:return_value_discarded
		t.interpolate_method(self, "change_text_value", 0, amount, duration)
# warning-ignore:return_value_discarded
		t.start()
		yield(t, "tween_completed")
#		t.queue_free()
		emit_signal("animation_finished")
	animation_active = false


func change_text_value(value: int = -1):
	if value != -1:
		text = str(value) + " " + tr(unit)
		return
	
	# Gambiarra for setting the label's size to the maximum amount will occupy
	var string = ""
	for i in amount % 10:
		string += "W"
	text = string + " " + tr(unit)


func skip():
	should_skip = true
	if t and is_instance_valid(t) and t.is_active():
# warning-ignore:return_value_discarded
		t.stop_all()
		change_text_value(amount)
	emit_signal("animation_finished")
	animation_active = false


func _on_EP_resized():
	rect_min_size.x = max(rect_min_size.x, rect_size.x)
