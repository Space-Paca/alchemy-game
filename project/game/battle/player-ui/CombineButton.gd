extends TextureButton

const ALPHA_SPEED = 4
const SCALE_SPEED = 2
const LABEL_HOVERED_SCALE = 1.1

var mouse_over := false

func _process(delta):
	if disabled:
		$Label.modulate.a = max($Label.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$Label.modulate.a = min($Label.modulate.a + ALPHA_SPEED*delta, 1)
	
	if mouse_over:
		$Label.rect_scale.x = min($Label.rect_scale.x + SCALE_SPEED*delta, LABEL_HOVERED_SCALE)
		$Label.rect_scale.y = min($Label.rect_scale.y + SCALE_SPEED*delta, LABEL_HOVERED_SCALE)
	else:
		$Label.rect_scale.x = max($Label.rect_scale.x - SCALE_SPEED*delta, 1)
		$Label.rect_scale.y = max($Label.rect_scale.y - SCALE_SPEED*delta, 1)

func enable():
	disabled = false

func disable():
	mouse_over = false
	disabled = true

func _on_CombineButton_button_down():
	AudioManager.play_sfx("click")

func _on_CombineButton_mouse_entered():
	if not disabled:
		mouse_over = true
		AudioManager.play_sfx("hover_button")

func _on_CombineButton_mouse_exited():
	mouse_over = false
