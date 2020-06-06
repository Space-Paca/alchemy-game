extends CanvasLayer

const FADE_DURATION = 1.5
const WAIT_TIME = 2

onready var tween = $Tween

func _ready():
	tween.interpolate_property($ColorRect, "modulate:a", 0, 1, 1.5)
	tween.start()
	
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(WAIT_TIME), "timeout")
	
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/main-menu/MainMenu.tscn")
