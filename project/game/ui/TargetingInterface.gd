extends Control
class_name TargetingInterface

onready var background := $Background
onready var label := $Label
onready var tween := $Tween

const TWEEN_DURATION := .3
const TEXT := "Choose target"
const FORMAT := "Choose target (%d/%d)"

var target_total := 0
var current_target := 0


func begin(total_targets: int):
	target_total = total_targets
	current_target = 0
	if target_total > 1:
		next_target()
	else:
		label.text = TEXT
	
	label.show()
	dim_background()


func next_target():
	current_target += 1
	if current_target <= target_total:
		label.text = FORMAT % [current_target, target_total]


func end():
	label.hide()
	clear_background()


func dim_background():
	tween.stop_all()
	tween.interpolate_property(background.get_material(), "shader_param/amount",
			null, 1, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func clear_background():
	tween.stop_all()
	tween.interpolate_property(background.get_material(), "shader_param/amount",
			null, 0, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
