extends Control

signal vanished

func setup(texture, value):
	$Image.texture = texture
	
	#Add value
	if value:
		$Value.text = str(value)
	else:
		$Value.text = ""
	
	#Random position for idle animation
	randomize()
	$AnimationPlayer.seek(rand_range(0,1.5))

func vanish():
	var dur = .2
	rect_pivot_offset = rect_size/2
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), dur/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2(1,1), Vector2(0,1), dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	emit_signal("vanished")
