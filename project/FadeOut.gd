extends CanvasLayer

const DURATION = 1.5

func _input(event):
	if event.is_action_pressed("fadeout"):
		$Tween.interpolate_property($ColorRect, "color", Color(0,0,0,0), Color(0,0,0,1), DURATION)
		$Tween.start()
		AudioManager.stop_bgm()
