extends VBoxContainer

signal back

onready var resolution_button = $TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/ResolutionButton
onready var resolution_dropdown = $TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/DropDown
onready var window_size_label = $TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/ResolutionButton/Label
onready var window_size_buttons = $TabContainer/Video/VBoxContainer/ResolutionContainer/Resolution/DropDown/ResolutionsContainer.get_children()
onready var fullscreen_button = $TabContainer/Video/VBoxContainer/FullscreenContainer/FullscreenCheckBox
onready var borderless_button = $TabContainer/Video/VBoxContainer/BorderlessContainer/BorderlessCheckBox
onready var mapfog_button = $TabContainer/Video/VBoxContainer/MapFog/MapFogCheckBox
onready var largeui_button = $TabContainer/Accesibility/VBoxContainer/LargeUI/LargeUICheckBox
onready var turbomode_button = $TabContainer/Gameplay/VBoxContainer/TurboModeContainer/TurboModeCheckBox
onready var colorblind_button = $TabContainer/Accesibility/VBoxContainer/ColorBlindness/ColorBlindnessCheckBox
onready var colorblindmode_button = $TabContainer/Accesibility/VBoxContainer/ColorblindModeContainer/ColorblindMode/ColorblindModeButton
onready var colorblindmode_dropdown = $TabContainer/Accesibility/VBoxContainer/ColorblindModeContainer/ColorblindMode/DropDown
onready var colorblindmode_label = $TabContainer/Accesibility/VBoxContainer/ColorblindModeContainer/ColorblindMode/ColorblindModeButton/Label
onready var colorblindmode_buttons = $TabContainer/Accesibility/VBoxContainer/ColorblindModeContainer/ColorblindMode/DropDown/ModesContainer.get_children()
onready var auto_end_button = $TabContainer/Gameplay/VBoxContainer/AutoPassContainer/AutoPassCheckBox
onready var show_timer_button = $TabContainer/Gameplay/VBoxContainer/ShowTimerContainer/ShowTimerCheckBox
onready var screen_shake_button = $TabContainer/Gameplay/VBoxContainer/ScreenShakeContainer/ScreenShakeCheckBox
onready var end_turn_button = $TabContainer/Controls/VBoxContainer/EndTurn/Button
onready var bgmslider = $TabContainer/Audio/VBoxContainer/MusicVolume
onready var bgm_label = $TabContainer/Audio/VBoxContainer/MusicLabel/Amount
onready var master_label = $TabContainer/Audio/VBoxContainer/MasterLabel/Amount
onready var masterslider = $TabContainer/Audio/VBoxContainer/MasterVolume
onready var sfxslider = $TabContainer/Audio/VBoxContainer/SFXVolume
onready var sfx_label = $TabContainer/Audio/VBoxContainer/SFXLabel/Amount
onready var tab_container = $TabContainer
onready var controls_buttons = {
	"show_recipe_book": $TabContainer/Controls/VBoxContainer/OpenCloseBook/Button,
	"combine": $TabContainer/Controls/VBoxContainer/Combine/Button,
	"end_turn": $TabContainer/Controls/VBoxContainer/EndTurn/Button,
	"toggle_fullscreen": $TabContainer/Controls/VBoxContainer/ToggleFullscreen/Button
}
onready var language_dropdown = $TabContainer/Language/VBoxContainer/LanguageContainer/Language/DropDown
onready var language_button = $TabContainer/Language/VBoxContainer/LanguageContainer/Language/LanguageButton
onready var language_label = $TabContainer/Language/VBoxContainer/LanguageContainer/Language/LanguageButton/Label
onready var language_buttons = $TabContainer/Language/VBoxContainer/LanguageContainer/Language/DropDown/ResolutionsContainer.get_children()

const SLIDER_COOLDOWN = .18
const TABS = ["VIDEO", "AUDIO", "CONTROLS", "GAMEPLAY", "LANGUAGE", "ACCESIBILITY"]

var is_keybinding = false
var keybinding = {"button": null, "action": "", "text": ""}
var slider_sfx_cooldown = 0


func _ready():
	for action in controls_buttons.keys():
		var button : Button = controls_buttons[action]
		# warning-ignore:return_value_discarded
		button.connect("toggled", self, "_on_ControlsButton_toggled",
				[action, button])
	
	for idx in tab_container.get_child_count():
		tab_container.set_tab_title(idx, TABS[idx])


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		if is_keybinding:
			cancel_keybinding()
		else:
			return
	elif event is InputEventKey and is_keybinding:
		bind_key(event.scancode)
	else:
		return
	
	get_tree().set_input_as_handled()


func _process(delta):
	slider_sfx_cooldown = max(slider_sfx_cooldown - delta, 0)


func update_buttons():
	var size_index = Profile.get_option("window_size")
	var size = Profile.WINDOW_SIZES[size_index]
	var locale_index = Profile.get_option("locale")
	var colorblind_index = Profile.get_option("colorblind_mode")
	window_size_label.text = str(size.x, "x", size.y)
	language_buttons[locale_index].pressed = true
	language_label.text = Profile.LANGUAGES[locale_index].name
	fullscreen_button.pressed = Profile.get_option("fullscreen")
	borderless_button.pressed = Profile.get_option("borderless")
	mapfog_button.pressed = Profile.get_option("disable_map_fog")
	largeui_button.pressed = Profile.get_option("large_ui")
	turbomode_button.pressed = Profile.get_option("turbo_mode")
	colorblind_button.pressed = Profile.get_option("enable_colorblind")
	auto_end_button.pressed = Profile.get_option("auto_end_turn")
	resolution_button.disabled = fullscreen_button.pressed
	resolution_dropdown.visible = false
	language_dropdown.visible = false
	colorblindmode_dropdown.visible = false
	colorblindmode_label.text = tr(ColorblindnessShader.MODES_NAME[colorblind_index])
	show_timer_button.pressed = Profile.get_option("show_timer")
	screen_shake_button.pressed = Profile.get_option("screen_shake")
	end_turn_button = Profile.get_option("auto_end_turn")
	window_size_buttons[size_index].pressed = true
	colorblindmode_buttons[colorblind_index].pressed = true


func update_music_volumes():
	masterslider.value = AudioManager.get_bus_volume(AudioManager.MASTER_BUS)*100
	master_label.text = str(masterslider.value)
	bgmslider.value = AudioManager.get_bus_volume(AudioManager.BGM_BUS)*100
	bgm_label.text = str(bgmslider.value)
	sfxslider.value = AudioManager.get_bus_volume(AudioManager.SFX_BUS)*100
	sfx_label.text = str(sfxslider.value)


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
	if visible and slider_sfx_cooldown <= 0:
		slider_sfx_cooldown = SLIDER_COOLDOWN
		AudioManager.play_sfx("click")


func close_dropdowns():
	if resolution_dropdown.visible:
		resolution_dropdown.visible = false
		resolution_button.pressed = false
	if language_dropdown.visible:
		language_dropdown.visible = false
		language_button.pressed = false
	if colorblindmode_dropdown.visible:
		colorblindmode_dropdown.visible = false
		colorblindmode_button.pressed = false


func _on_MasterVolume_value_changed(value):
	play_slider_sfx()
	AudioManager.set_bus_volume(AudioManager.MASTER_BUS,
			value/float(masterslider.max_value))
	master_label.text = str(value)
	Profile.set_option("master_volume", value/float(masterslider.max_value))


func _on_SFXVolume_value_changed(value):
	play_slider_sfx()
	AudioManager.set_bus_volume(AudioManager.SFX_BUS, value/float(sfxslider.max_value))
	sfx_label.text = str(value)
	Profile.set_option("sfx_volume", value/float(sfxslider.max_value))


func _on_MusicVolume_value_changed(value):
	AudioManager.set_bus_volume(AudioManager.BGM_BUS, value/float(bgmslider.max_value))
	bgm_label.text = str(value)
	Profile.set_option("bgm_volume", value/float(bgmslider.max_value))


func _on_Back_pressed():
	AudioManager.play_sfx("click")
	if is_keybinding:
		keybinding.button.pressed = false
	else:
		close_dropdowns()
		emit_signal("back")


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
	if button_id != Profile.get_option("window_size"):
		var size = Profile.WINDOW_SIZES[button_id]
		window_size_label.text = str(size.x, "x", size.y)
		OS.window_size = size
		Profile.set_option("window_size", button_id)
	
	AudioManager.play_sfx("close_filter")
	close_dropdowns()


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


func _on_ResetTutorial_pressed():
	AudioManager.play_sfx("click")
	Profile.reset_tutorials()


func _on_AutoPassCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("auto_end_turn", button_pressed)


func _on_ShowTimerCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("show_timer", button_pressed)


func _on_LanguageButton_toggled(button_pressed):
	language_dropdown.visible = button_pressed
	if button_pressed:
		AudioManager.play_sfx("open_filter")
	else:
		AudioManager.play_sfx("close_filter")


func _on_LanguageButton_pressed(button_id: int):
	AudioManager.play_sfx("click")
	language_dropdown.visible = false
	language_button.pressed = false
	if button_id == Profile.get_option("locale"):
		return
	
	var lang = Profile.LANGUAGES[button_id]
	language_label.text = lang.name
	TranslationServer.set_locale(lang.locale)
	Profile.set_option("locale", button_id)


func _on_MapFogCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("disable_map_fog", button_pressed)


func _on_tab_changed(_tab):
	AudioManager.play_sfx("changed_pause_tab")
	close_dropdowns()

func _on_MusicVolume_focus_entered():
	AudioManager.disable_bgm_filter_effect()


func _on_MasterVolume_focus_entered():
	AudioManager.disable_bgm_filter_effect()


func _on_MasterVolume_focus_exited():
	AudioManager.enable_bgm_filter_effect()


func _on_MusicVolume_focus_exited():
	AudioManager.enable_bgm_filter_effect()


func _on_CloseDropdown_pressed():
	AudioManager.play_sfx("close_filter")
	close_dropdowns()


func _on_ScreenShakeCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("screen_shake", button_pressed)


func _on_LargeUICheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("large_ui", button_pressed)


func _on_ColorBlindnessCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("enable_colorblind", button_pressed)
	if button_pressed:
		ColorblindnessShader.enable()
	else:
		ColorblindnessShader.disable()


func _on_ColorblindModeButton_toggled(button_pressed):
	colorblindmode_dropdown.visible = button_pressed
	if button_pressed:
		AudioManager.play_sfx("open_filter")
	else:
		AudioManager.play_sfx("close_filter")


func _on_ColorblindMode_button_pressed(button_id: int):
	AudioManager.play_sfx("click")
	if button_id != Profile.get_option("colorblind_mode"):
		colorblindmode_label.text = tr(ColorblindnessShader.MODES_NAME[button_id])
		ColorblindnessShader.set_mode(button_id)
		Profile.set_option("colorblind_mode", button_id)
	
	AudioManager.play_sfx("close_filter")
	close_dropdowns()


func _on_TurboModeCheckBox_toggled(button_pressed):
	AudioManager.play_sfx("click")
	Profile.set_option("turbo_mode", button_pressed)
