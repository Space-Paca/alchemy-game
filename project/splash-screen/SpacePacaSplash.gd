extends ColorRect

func _ready():
	pass


func _unhandled_input(event):
	if event.is_action_pressed("combine"):
		$SpacePacaLogo/AnimationPlayer.play("anim")
	elif event.is_action_pressed("end_turn"):
		$SpacePacaLogo/AnimationPlayer.play("RESET")
