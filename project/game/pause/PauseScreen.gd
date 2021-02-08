extends CanvasLayer

enum Modes {DUNGEON, MENU}
export(Modes) var mode

onready var bg = $Background
onready var menu = $Background/Menu
onready var confirm = $Background/ConfirmMenu
onready var bgmslider = $Background/Menu/MusicVolume
onready var sfxslider = $Background/Menu/SFXVolume

const AUDIO_FILTER = preload("res://game/pause/pause_audio_filter.tres")
const SLIDER_COOLDOWN = .18


var paused := false
var slider_sfx_cooldown = 0


func _ready():
	bg.hide()
	
	update_music_volumes()
	
	if mode == Modes.MENU:
		$Background/Menu/Return.hide()


func _process(delta):
	slider_sfx_cooldown = max(slider_sfx_cooldown - delta, 0)


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		if confirm.visible:
			no_quit()
		elif not TutorialLayer.is_active():
			toggle_pause()


func toggle_pause():
	set_pause(!paused)


func set_pause(p: bool):
	paused = p
	get_tree().paused = p
	bg.visible = p
	if p:
		AudioServer.add_bus_effect(0, AUDIO_FILTER)
		update_music_volumes()
	else:
		AudioServer.remove_bus_effect(0, 0)


func no_quit():
	confirm.hide()
	menu.show()


func update_music_volumes():
	bgmslider.value = AudioManager.get_bus_volume("bgm")*100
	sfxslider.value = AudioManager.get_bus_volume("sfx")*100


func play_slider_sfx():
	if bg.visible and slider_sfx_cooldown <= 0:
		slider_sfx_cooldown = SLIDER_COOLDOWN
		AudioManager.play_sfx("click")


func _on_Resume_pressed():
	toggle_pause()


func _on_Return_pressed():
	set_pause(false)
	AudioManager.stop_all_enemy_idle_sfx()
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")


func _on_Exit_pressed():
	menu.hide()
	confirm.show()


func _on_Yes_pressed():
	FileManager.save_and_quit()


func _on_No_pressed():
	no_quit()


func _on_SFXVolume_value_changed(value):
	play_slider_sfx()
	AudioManager.set_bus_volume("sfx", value/float(sfxslider.max_value))
	Profile.set_option("sfx_volume", value/float(sfxslider.max_value))


func _on_MusicVolume_value_changed(value):
	AudioManager.set_bus_volume("bgm", value/float(bgmslider.max_value))
	Profile.set_option("bgm_volume", value/float(bgmslider.max_value))

func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")
