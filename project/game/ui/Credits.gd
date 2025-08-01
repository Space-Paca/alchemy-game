extends Control

signal continue_credits

func _on_Continue_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_Continue_pressed():
	emit_signal("continue_credits")
