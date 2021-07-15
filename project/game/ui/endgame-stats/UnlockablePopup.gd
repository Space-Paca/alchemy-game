extends ColorRect

signal closed


func setup(unlock_data: Dictionary):
	$BG/VBoxContainer/Title.text = unlock_data.name
	$BG/VBoxContainer/Type.text = unlock_data.type
	$BG/TextureRect.texture = unlock_data.texture
	$BG/Description.text = unlock_data.description


func _on_Continue_pressed():
	AudioManager.play_sfx("click")
	emit_signal("closed")
