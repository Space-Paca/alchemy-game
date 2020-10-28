extends TextureButton

func _on_CombineButton_button_down():
	AudioManager.play_sfx("click")

func _on_CombineButton_mouse_entered():
	if not disabled:
		AudioManager.play_sfx("hover_button")
