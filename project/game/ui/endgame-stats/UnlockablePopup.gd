extends ColorRect


func set_title(t: String):
	$BG/VBoxContainer/Title.text = t


func set_type(t: String):
	$BG/VBoxContainer/Type.text = t


func set_texture(t: Texture):
	$BG/TextureRect.texture = t


func set_description(d: String):
	$BG/Description.text = d


func _on_Continue_pressed():
	AudioManager.play_sfx("click")
	hide()
