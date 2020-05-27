extends Node2D

func setup(value):
	if value <= 0:
		$Label.text = str(value)
		$AnimationPlayer.play("decrease")
	else:
		$Label.text = "+" + str(value)
		$AnimationPlayer.play("increase")

func finished():
	queue_free()
