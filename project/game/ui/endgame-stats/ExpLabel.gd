extends Label

signal animation_finished

export var unit := " XP"
export var base_duration := .05

var amount := 0

func _ready():
	text = "0" + unit


func animate():
	print(self)
	var t = Tween.new()
	add_child(t)
	t.interpolate_method(self, "change_text_value", 0, amount, base_duration * amount)
	t.start()
	yield(t, "tween_completed")
	emit_signal("animation_finished")
	t.queue_free()


func change_text_value(value: int):
	text = str(value) + unit
