extends Control

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
