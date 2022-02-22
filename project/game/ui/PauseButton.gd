extends TextureButton

const LERP_SPEED = 7.0

var blocked = false

func _process(dt):
	if blocked:
		modulate.r = lerp(modulate.r, .3, dt*LERP_SPEED)
		modulate.g = lerp(modulate.g, .3, dt*LERP_SPEED)
		modulate.b = lerp(modulate.b, .3, dt*LERP_SPEED)
	else:
		modulate.r = lerp(modulate.r, 1.0, dt*LERP_SPEED)
		modulate.g = lerp(modulate.g, 1.0, dt*LERP_SPEED)
		modulate.b = lerp(modulate.b, 1.0, dt*LERP_SPEED)


func set_blocked(value):
	blocked = value
