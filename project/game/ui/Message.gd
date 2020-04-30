extends Control
class_name Message

signal disappeared

onready var label : Label = $Label
onready var tween : Tween = $Tween

export(float) var y_offset
export(float) var animation_duration


func set_text(text: String):
	label.text = text


func animate(shown_duration: float):
	# POSITION IN
	tween.interpolate_property(label, "rect_position:y",
			label.rect_position.y + y_offset, label.rect_position.y,
			animation_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	# POSITION OUT
	tween.interpolate_property(label, "rect_position:y", null,
			label.rect_position.y - y_offset, animation_duration,
			Tween.TRANS_CUBIC, Tween.EASE_IN, animation_duration + shown_duration)
	# OPACITY IN
	tween.interpolate_property(label, "modulate:a", 0, 1, animation_duration,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	# OPACITY OUT
	tween.interpolate_property(label, "modulate:a", 1, 0, animation_duration,
			Tween.TRANS_CUBIC, Tween.EASE_IN, animation_duration + shown_duration)
	
	tween.start()
	
	yield(get_tree().create_timer(2 * animation_duration + shown_duration),
			"timeout")
	emit_signal("disappeared", self)
