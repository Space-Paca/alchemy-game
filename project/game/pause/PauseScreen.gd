extends CanvasLayer

const TABS = ["VIDEO", "AUDIO", "CONTROLS", "GAMEPLAY", "LANGUAGE"]

enum Modes {DUNGEON, MENU}
export(Modes) var mode

signal exited_pause

onready var bg = $Background
onready var screen_title = $Background/Label
onready var menu = $Background/Menu
onready var confirm = $Background/ConfirmMenu
onready var exit_button = $Background/Menu/Exit
onready var settings = $Background/SettingsMenu
onready var bgmslider = $Background/SettingsMenu/TabContainer/Audio/VBoxContainer/MusicVolume
onready var sfxslider = $Background/SettingsMenu/TabContainer/Audio/VBoxContainer/SFXVolume
onready var resolution_dropdown = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/DropDown
onready var language_dropdown = $Background/SettingsMenu/TabContainer/Language/VBoxContainer/LanguageContainer/Language/DropDown
onready var fullscreen_button = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/FullscreenContainer/FullscreenCheckBox
onready var borderless_button = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/BorderlessContainer/BorderlessCheckBox
onready var mapfog_button = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/MapFog/MapFogCheckBox
onready var auto_end_button = $Background/SettingsMenu/TabContainer/Gameplay/VBoxContainer/AutoPassContainer/AutoPassCheckBox
onready var window_size_label = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/ResolutionButton/Label
onready var window_size_buttons = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/DropDown/ResolutionsContainer.get_children()
onready var language_label = $Background/SettingsMenu/TabContainer/Language/VBoxContainer/LanguageContainer/Language/LanguageButton/Label
onready var language_buttons = $Background/SettingsMenu/TabContainer/Language/VBoxContainer/LanguageContainer/Language/DropDown/ResolutionsContainer.get_children()
onready var resolution_button = $Background/SettingsMenu/TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/ResolutionButton
onready var language_button = $Background/SettingsMenu/TabContainer/Language/VBoxContainer/LanguageContainer/Language/LanguageButton
onready var tab_container = $Background/SettingsMenu/TabContainer
onready var show_timer_button = $Background/SettingsMenu/TabContainer/Gameplay/VBoxContainer/ShowTimerContainer/ShowTimerCheckBox
onready var end_turn_button = $Background/SettingsMenu/TabContainer/Controls/VBoxContainer/EndTurn/Button
onready var controls_buttons = {"show_recipe_book": $Background/SettingsMenu/TabContainer/Controls/VBoxContainer/OpenCloseBook/Button,
"combine": $Background/SettingsMenu/TabContainer/Controls/VBoxContainer/Combine/Button, "end_turn": $Background/SettingsMenu/TabContainer/Controls/VBoxContainer/EndTurn/Button,
"toggle_fullscreen": $Background/SettingsMenu/TabContainer/Controls/VBoxContainer/ToggleFullscreen/Button}

const AUDIO_FILTER = preload("res://game/pause/pause_audio_filter.tres")
const SLIDER_COOLDOWN = .18


var paused := false
var slider_sfx_cooldown = 0
var block_pause = false
var is_keybinding = false
var keybinding = {"button": null, "action": "", "text": ""}


func _ready():
	bg.hide()
	
	if mode == Modes.MENU:
		$Background/Menu/Return.hide()
		exit_button.text = "EXIT_DESKTOP"
	else:
		exit_button.text = "SAVE_RETURN_DESKTOP"
	
	for action in controls_buttons.keys():
		var button : Button = controls_buttons[action]
# warning-ignore:return_value_discarded
		button.connect("toggled", self, "_on_ControlsButton_toggled",
				[action, button])
	
	for idx in tab_container.get_child_count():
		tab_container.set_tab_title(idx, TABS[idx])


func _process(delta):
	slider_sfx_cooldown = max(slider_sfx_cooldown - delta, 0)


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		if is_keybinding:
			cancel_keybinding()
		elif confirm.visible:
			no_quit()
		elif settings.visible:
			settings_back()
		elif not TutorialLayer.is_active():
			toggle_pause()
	elif event is InputEventKey and is_keybinding:
		bind_key(event.scancode)


func toggle_pause():
	if block_pause or Transition.active:
		AudioManager.play_sfx("error")
		return
	set_pause(!paused)


func set_pause(p: bool):
	paused = p
	get_tree().paused = p
	bg.visible = p
	if p:
		AudioServer.add_bus_effect(0, AUDIO_FILTER)
		update_music_volumes()
		update_buttons()
		update_controls()
	else:
		AudioServer.remove_bus_effect(0, 0)
		FileManager.save_profile()
		emit_signal("exited_pause")


func no_quit():
	confirm.hide()
	menu.show()


func set_block_pause(value: bool):
	block_pause = value


func settings_back():
	screen_title.text = "GAME_PAUSED"
	settings.hide()
	menu.show()


func update_music_volumes():
	bgmslider.value = AudioManager.get_bus_volume("bgm")*100
	sfxslider.value = AudioManager.get_bus_volume("sfx")*100


func update_buttons():
	var index = Profile.get_option("window_size")
	var size = Profile.WINDOW_SIZES[index]
	window_size_buttons[index].pressed = true
	window_size_label.text = str(size.x, "x", size.y)
	index = Profile.get_option("locale")
	var lang = Profile.LANGUAGES[index]
	language_buttons[index].pressed = true
	language_label.text = lang.name
	fullscreen_button.pressed = Profile.get_option("fullscreen")
	borderless_button.pressed = Profile.get_option("borderless")
	mapfog_button.pressed = Profile.get_option("disable_map_fog")
	auto_end_button.pressed = Profile.get_option("auto_end_turn")
	resolution_button.disabled = fullscreen_button.pressed
	resolution_dropdown.visible = false
	language_dropdown.visible = false
	show_timer_button.pressed = Profile.get_option("show_timer")
	end_turn_button = Profile.get_option("auto_end_turn")


func update_controls():
	for action in controls_buttons.keys():
		var button : Button = controls_buttons[action]
		button.text = OS.get_scancode_string(Profile.get_control(action))


func bind_key(scancode: int):
	for action in controls_buttons.keys():
		if action == keybinding.action:
			continue
		
		if scancode == Profile.get_control(action):
			var current_sc = Profile.get_control(keybinding.action)
			controls_buttons[action].text = OS.get_scancode_string(current_sc)
			Profile.set_control(action, current_sc)
	
	keybinding.text = OS.get_scancode_string(scancode)
	Profile.set_control(keybinding.action, scancode)
	
	keybinding.button.pressed = false


func cancel_keybinding():
	keybinding.button.text = keybinding.text
	is_keybinding = false
	keybinding.button = null
	keybinding.action = ""
	keybinding.text = ""


func play_slider_sfx():
	if bg.visible and slider_sfx_cooldown <= 0:
		slider_sfx_cooldown = SLIDER_COOLDOWN
		AudioManager.play_sfx("click")


func _on_Resume_pressed():
	toggle_pause()


func _on_Return_pressed():
	set_pause(false)
	AudioManager.stop_all_enemy_idle_sfx()
	if FileManager.current_run_exists():
		FileManager.save_run()
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


func _on_ResetTutorial_pressed():
	Profile.reset_tutorials()


func _on_Settings_pressed():
	screen_title.text = "SETTINGS"
	menu.hide()
	settings.show()


func _on_Back_pressed():
	if is_keybinding:
		keybinding.button.pressed = false
	else:
		settings_back()


func _on_ResolutionButton_toggled(button_pressed):
	resolution_dropdown.visible = button_pressed
	if button_pressed:
		AudioManager.play_sfx("open_filter")
	else:
		AudioManager.play_sfx("close_filter")


func _on_FullscreenCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	OS.window_fullscreen = button_pressed
	Profile.set_option("fullscreen", button_pressed)
	resolution_button.disabled = button_pressed


func _on_BorderlessCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	OS.window_borderless = button_pressed
	Profile.set_option("borderless", button_pressed)


func _on_Resolution_button_pressed(button_id: int):
	AudioManager.play_sfx("click")
	if button_id == Profile.get_option("window_size"):
		return
	
	var size = Profile.WINDOW_SIZES[button_id]
	window_size_label.text = str(size.x, "x", size.y)
	OS.window_size = size
	Profile.set_option("window_size", button_id)


func _on_ControlsButton_toggled(_button_pressed: bool, action: String,
		button: Button):
	if is_keybinding and keybinding.button == button:
		cancel_keybinding()
		return
	elif is_keybinding:
		keybinding.button.pressed = false
	
	is_keybinding = true
	keybinding.button = button
	keybinding.action = action
	keybinding.text = button.text
	
	button.text = "..."

func _on_AutoPassCheckBox_toggled(button_pressed):
	Profile.set_option("auto_end_turn", button_pressed)


func _on_ShowTimerCheckBox_toggled(button_pressed):
	Profile.set_option("show_timer", button_pressed)


func _on_LanguageButton_toggled(button_pressed):
	language_dropdown.visible = button_pressed
	if button_pressed:
		AudioManager.play_sfx("open_filter")
	else:
		AudioManager.play_sfx("close_filter")


func _on_Language_Button_pressed(button_id: int):
	AudioManager.play_sfx("click")
	language_dropdown.visible = false
	if button_id == Profile.get_option("locale"):
		return
	
	var lang = Profile.LANGUAGES[button_id]
	language_label.text = lang.name
	TranslationServer.set_locale(lang.locale)
	Profile.set_option("locale", button_id)


func _on_MapFogCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("disable_map_fog", button_pressed)
