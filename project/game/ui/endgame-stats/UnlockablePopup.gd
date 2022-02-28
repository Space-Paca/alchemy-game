extends ColorRect

signal closed

const MAX_TITLE_FONT_SIZE = 208
const MAX_TYPE_FONT_SIZE = 85
const DEFAULT_MARGIN = 16
const BGS = {
	"recipes": preload("res://assets/images/ui/recompensa1.png"),
	"artifacts": preload("res://assets/images/ui/recompensa2.png"),
	"misc": preload("res://assets/images/ui/recompensa3.png"),
}
const FONT_COLOR = {
	"recipes": Color(0xffba8cff),
	"artifacts": Color(0x8cc1ffff),
	"misc": Color(0x8cffbcff),
}
const TITLE_COLOR = {
	"recipes": Color(0x6d3317ff),
	"artifacts": Color(0x176d6bff),
	"misc": Color(0x176d51ff),
}

func setup(unlock_data: Dictionary):
	$BG.texture = BGS[unlock_data.style]
	$BG/UnlockLabel.set("custom_colors/font_color", FONT_COLOR[unlock_data.style])
	$BG/VBoxContainer/Title.text = unlock_data.name
	$BG/VBoxContainer/Title.modulate = TITLE_COLOR[unlock_data.style]
	update_label_size($BG/VBoxContainer/Title, MAX_TITLE_FONT_SIZE)
	$BG/VBoxContainer/Type.text = unlock_data.type
	update_label_size($BG/VBoxContainer/Type, MAX_TYPE_FONT_SIZE)
	$BG/TextureRect.texture = unlock_data.texture
	$BG/TextureRect/Shadow.texture = unlock_data.texture
	$BG/Description.text = unlock_data.description

func update_label_size(label, max_size):
	var font = label.get("custom_fonts/font")
	font.set("size", max_size)
	var font_size = max_size
	while label.get_visible_line_count() < label.get_line_count():
		font_size = font_size-15
		font.set("size", font_size)


func appear():
	$AnimationPlayer.play("appear")


func _on_Continue_pressed():
	AudioManager.play_sfx("click")
	emit_signal("closed")


func _on_Continue_mouse_entered():
	AudioManager.play_sfx("hover_button")
