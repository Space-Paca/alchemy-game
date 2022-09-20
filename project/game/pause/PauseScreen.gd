extends CanvasLayer

enum Modes {DUNGEON, MENU}
export(Modes) var mode

const ALPHA_SPEED = 7.0

signal exited_pause
signal block_pause_update

onready var bg = $Background
onready var screen_title = $Background/Label
onready var menu = $Background/Menu
onready var confirm = $Background/ConfirmMenu
onready var exit_button = $Background/Menu/Exit
onready var settings = $Background/SettingsMenu

var paused := false
var block_pause = false


func _ready():
	bg.modulate.a = 0
	bg.hide()
	
	if mode == Modes.MENU:
		$Background/Menu/Return.hide()
		exit_button.text = "EXIT_DESKTOP"
	else:
		exit_button.text = "SAVE_RETURN_DESKTOP"


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		if confirm.visible:
			no_quit()
		elif settings.visible:
			settings_back()
		elif not TutorialLayer.is_active():
			toggle_pause()
		else:
			return
		get_tree().set_input_as_handled()


func _process(dt):
	if paused:
		bg.modulate.a = min(bg.modulate.a + ALPHA_SPEED*dt, 1.0)
		if bg.modulate.a > 0.0:
			bg.show()
	else:
		bg.modulate.a = max(bg.modulate.a - ALPHA_SPEED*dt, 0.0)
		if bg.modulate.a <= 0.0:
			bg.hide()


func toggle_pause():
	if block_pause or Transition.active:
		AudioManager.play_sfx("error")
		return
	set_pause(!paused)


func set_pause(p: bool):
	paused = p
	get_tree().paused = p
	if p:
		AudioManager.enable_bgm_filter_effect()
		settings.update_music_volumes()
		settings.update_buttons()
		settings.update_controls()
	else:
		AudioManager.disable_bgm_filter_effect()
		FileManager.save_profile()
		emit_signal("exited_pause")


func is_paused():
	return paused


func no_quit():
	confirm.hide()
	menu.show()


func set_block_pause(value: bool):
	block_pause = value
	emit_signal("block_pause_update", block_pause)


func settings_back():
	screen_title.text = "GAME_PAUSED"
	settings.hide()
	menu.show()


func set_mouse_filter(should_block):
	for node in [menu, confirm, settings]:
		if should_block:
			node.mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for node in [bg, screen_title]:
		if should_block:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_Resume_pressed():
	AudioManager.play_sfx("click")
	toggle_pause()


func _on_Return_pressed():
	AudioManager.play_sfx("click")
	set_pause(false)
	AudioManager.stop_all_enemy_idle_sfx()
	if FileManager.current_run_exists():
		FileManager.save_run()
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")


func _on_Exit_pressed():
	AudioManager.play_sfx("click")
	menu.hide()
	confirm.show()


func _on_Yes_pressed():
	AudioManager.play_sfx("click")
	FileManager.save_and_quit()


func _on_No_pressed():
	AudioManager.play_sfx("click")
	no_quit()


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_Settings_pressed():
	AudioManager.play_sfx("click")
	screen_title.text = "SETTINGS"
	menu.hide()
	settings.show()

