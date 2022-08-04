extends ColorRect

signal closed

const MAX_TITLE_FONT_SIZE = 208
const MAX_TYPE_FONT_SIZE = 85
const DEFAULT_MARGIN = 16
const INFO ={
	"recipes": {
		"bg": preload("res://assets/images/ui/recompensa1.png"),
		"font_color": Color(0xffba8cff),
		"title_color": Color(0x6d3317ff),
		"particle_color": Color(0xff4200ff),
		"continue_color": Color(0xff6013ff),
	},
	"artifacts": {
		"bg": preload("res://assets/images/ui/recompensa2.png"),
		"font_color": Color(0x8cc1ffff),
		"title_color": Color(0x176d6bff),
		"particle_color": Color(0x0fffe3ff),
		"continue_color": Color(0x6283f2ff),
	},
	"misc": {
		"bg": preload("res://assets/images/ui/recompensa3.png"),
		"font_color": Color(0x8cffbcff),
		"title_color": Color(0x176d51ff),
		"particle_color": Color(0xffb80fff),
		"continue_color": Color(0xff9610ff),
	},
}

var active = false
var sfx = null


func _input(event):
	if active:
		if event.is_action_pressed("ui_accept") or\
		   event.is_action_pressed("ui_cancel") or\
		   event.is_action_pressed("ui_select"):
			close()


func setup(unlock_data: Dictionary):
	$BG.texture = INFO[unlock_data.style].bg
	$BG/UnlockLabel.set("custom_colors/font_color", INFO[unlock_data.style].font_color)
	$BG/VBoxContainer/Title.text = unlock_data.name
	$BG/VBoxContainer/Title.modulate = INFO[unlock_data.style].title_color
	update_label_size($BG/VBoxContainer/Title, MAX_TITLE_FONT_SIZE)
	$BG/VBoxContainer/Type.text = unlock_data.type
	update_label_size($BG/VBoxContainer/Type, MAX_TYPE_FONT_SIZE)
	$BG/TextureRect.texture = unlock_data.texture
	$BG/TextureRect/Shadow.texture = unlock_data.texture
	$BG/Description.text = unlock_data.description
	$BG/Continue.modulate = INFO[unlock_data.style].continue_color
	$BG/ContinueParticles.modulate = INFO[unlock_data.style].particle_color
	sfx = unlock_data.sfx

func update_label_size(label, max_size):
	var font = label.get("custom_fonts/font")
	font.set("size", max_size)
	var font_size = max_size
	while label.get_visible_line_count() < label.get_line_count():
		font_size = font_size-15
		font.set("size", font_size)


func appear():
	active = true
	$AnimationPlayer.play("appear")
	$Tween.interpolate_property($LoopSFX, "volume_db", -80, 0, 1.0)
	$Tween.start()


func close():
	active = false
	AudioManager.play_sfx("click")
	$Tween.remove_all()
	$Tween.interpolate_property($LoopSFX, "volume_db", $LoopSFX.volume_db, -80, .5)
	$Tween.start()
	emit_signal("closed")


func play_sfx():
	AudioManager.play_sfx(sfx)


func _on_Continue_pressed():
	close()


func _on_Continue_mouse_entered():
	AudioManager.play_sfx("hover_button")
