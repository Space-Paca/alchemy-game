extends Control

const ALPHA_SPEED = 6
const SHEEN_DUR = .8
const SHEEN_INTERVAL = 5.0
const BGM_STOP_SPEED = 7.0
const BUTTON_GROWTH_LERP_FACTOR = .3
const GROWING_BUTTON_WIDTH = {
	"original": 220,
	"discord": {
		"en": 350,
		"pt_BR": 470,
	},
	"steam": {
		"en": 370,
		"pt_BR": 735,
	},
	"updates": {
		"en": 465,
		"pt_BR": 520,
	},
}
const SEASONAL_MOD = {
	"halloween": {
		"ui": Color("ff9126"),
		"font": Color("000000"),
	},
	"eoy_holidays": {
		"ui": Color("00d3f6"),
		"font": Color("c1feff"),
	},
}

onready var anim = $AnimationPlayer
onready var sheen_tween = $Title/TitleSheen/Tween
onready var sheen_timer = $Title/TitleSheen/SheenTimer
onready var sheen_material = $Title/TitleSheen.material
onready var compendium_button = $CompendiumButton
onready var buttons = [$ContinueButton, $NewGameButton, $QuitButton]
onready var growing_buttons = {
	"discord": $VBoxContainer/Discord,
	"steam": $VBoxContainer/Steam,
	"updates": $VBoxContainer/Updates,
}
onready var quit_yes_button = $QuitConfirm/VBoxContainer/HBoxContainer/Yes
onready var quit_no_button = $QuitConfirm/VBoxContainer/HBoxContainer/No
onready var popup_back_button = $PopupBG/Panel/HBoxContainer/Back
onready var popup_confirm_button = $PopupBG/Panel/HBoxContainer/Confirm
onready var seasonal_particles = {
	"eoy_holidays": $SnowParticles
}

var hover_compendium = false
var is_hovered = {
	"discord": false,
	"steam": false,
	"updates": false,
}

func _ready():
	
	anim.play("reset")
	sheen_timer.wait_time = SHEEN_INTERVAL
	
	if not Debug.is_steam or Debug.is_demo:
		growing_buttons.steam.show()
	else:
		growing_buttons.steam.hide()
	
	if Debug.seasonal_event:
		set_seasonal_look(Debug.seasonal_event)
		if $SeasonalAnimation.has_animation(Debug.seasonal_event):
			$SeasonalAnimation.play(Debug.seasonal_event)
	
	for button in buttons:
		button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
	for button in growing_buttons.values():
		button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
	
	
	FileManager.set_current_run(false)
	set_process_input(false)
	compendium_button.visible = UnlockManager.is_misc_unlocked("COMPENDIUM")
	
	yield(get_tree(),"idle_frame")
	
	AudioManager.play_bgm("menu", false, true)
	$ContinueButton.visible = FileManager.run_file_exists()
	
	yield(Transition, "finished")
	
	if FileManager.run_file_exists():
		anim.play("intro")
	else:
		anim.play("intro-no-continue")
	
	set_process_input(true)
	AchievementManager.check_for_all()

# (❁´◡`❁)

func _process(dt):
	var label = $CompendiumButton/Label
	if hover_compendium:
		label.modulate.a = min(label.modulate.a + ALPHA_SPEED*dt, 1.0)
	else:
		label.modulate.a = max(label.modulate.a - ALPHA_SPEED*dt, 0.0)
	
	for btn_name in ["discord", "steam", "updates"]:
		var btn : Button = growing_buttons[btn_name]
		var target_width = GROWING_BUTTON_WIDTH[btn_name][TranslationServer.get_locale()] if is_hovered[btn_name] else GROWING_BUTTON_WIDTH.original
		btn.rect_size.x = lerp(btn.rect_size.x, target_width,
				BUTTON_GROWTH_LERP_FACTOR)


func _input(event):
	if anim.is_playing() and (event.is_action_pressed("left_mouse_button") or \
			event.is_action_pressed("quit")):
		skip_intro_animation()
	
	if $QuitConfirm.visible and event.is_action_pressed("quit") :
		 $PauseScreen.toggle_pause()#Toggle pause again so it actually doesn't pauses
	elif event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		Profile.set_option("fullscreen", OS.window_fullscreen, true)
		if not OS.window_fullscreen:
			yield(get_tree(), "idle_frame")
			OS.window_size = Profile.WINDOW_SIZES[Profile.get_option("window_size")]
			OS.window_position = Vector2(0,0)


func set_seasonal_look(event_string):
	var theme = get_theme()
	theme.set_theme_item(Theme.DATA_TYPE_COLOR, "font_color", "Button", SEASONAL_MOD[event_string].font)
	theme.set_theme_item(Theme.DATA_TYPE_COLOR, "font_color_focus", "Button", SEASONAL_MOD[event_string].font)
	theme.set_theme_item(Theme.DATA_TYPE_COLOR, "font_color_hover", "Button", SEASONAL_MOD[event_string].font)
	for style_name in ["hover", "pressed", "normal", "disabled"]:
		var style = theme.get_stylebox(style_name, "Button")
		style.modulate_color = SEASONAL_MOD[event_string].ui
	
	var path = "res://assets/images/main_menu/%s/" % event_string
	var data_res = $Background.animation_state_data_res
	var skeleton = data_res.skeleton
	skeleton.disconnect("atlas_res_changed", data_res, "_on_skeleton_data_changed")
	skeleton.atlas_res = load("res://assets/spine/mainmenu/start screen_spine_%s.atlas" % event_string)
	$Title.texture = load(path + "title.png")
	$Title/TitleSheen.texture = load(path + "title.png")
	$Frame.texture = load(path + "border.png")
	$SpinningThing.texture = load(path + "lines.png")
	$SpinningThing/Part1.texture = load(path + "circle 2_big.png")
	$SpinningThing/Part2.texture = load(path + "half_moon1.png")
	$SpinningThing/Part3.texture = load(path + "circle.png")
	$SpinningThing/Part4.texture = load(path + "circle 2_big.png")
	$BackTitleDetail.texture = load(path + "Camada 19.png")
	$Subtitle.texture = load(path + "sub titulo.png")
	
	for node in [$ContinueButton, $NewGameButton, $QuitButton,
			$VBoxContainer/Updates, $VBoxContainer/Discord, $VBoxContainer/Steam,
			quit_yes_button, quit_no_button, popup_confirm_button, popup_back_button]:
		#Button color
		for style_name in ["hover", "pressed", "normal", "disabled"]:
			var style = node.get_stylebox(style_name)
			style.modulate_color = SEASONAL_MOD[event_string].ui
		#Fonts color
		node.add_color_override("font_color", SEASONAL_MOD[event_string].font)
		node.add_color_override("font_color_hover", SEASONAL_MOD[event_string].font)
		node.add_color_override("font_color_pressed", SEASONAL_MOD[event_string].font)
		node.add_color_override("font_color_focus", SEASONAL_MOD[event_string].font)
	
	#Particles
	seasonal_particles[event_string].show()
	
	path = "res://assets/images/ui/%s/" % event_string
	$VBoxContainer/Updates.icon = load(path + "logo_update__alchemia.png")
	$VBoxContainer/Discord.icon = load(path + "logo_discord__alchemia.png")
	$VBoxContainer/Steam.icon = load(path + "logo_steam__alchemia.png")


func skip_intro_animation():
	anim.seek(anim.get_animation("intro").length, true)
	for button in buttons:
		button.disabled = true
	yield(get_tree(), "idle_frame")
	for button in buttons:
		button.disabled = false


func start_game(continue_save := false):
	if continue_save:
		FileManager.continue_game = true
		AudioManager.stop_bgm(BGM_STOP_SPEED)
		AudioManager.play_sfx("start_new_game")
		Transition.transition_to("res://game/dungeon/Dungeon.tscn")
	else:
		Transition.transition_to("res://game/pre-run/PreRunScreen.tscn")


func _on_NewGameButton_pressed():
	if FileManager.run_file_exists():
		$PopupBG.show()
	else:
		start_game(false)


func _on_QuitButton_pressed():
	AudioManager.play_sfx("click")
	$QuitConfirm.show()


func _on_Yes_pressed():
	AudioManager.play_sfx("click")
	FileManager.save_and_quit()


func _on_No_pressed():
	AudioManager.play_sfx("click")
	$QuitConfirm.hide()


func _on_PauseButton_pressed():
	$PauseScreen.toggle_pause()


func _on_PauseButton_mouse_entered():
	if not $UI/PauseButton.disabled:
		AudioManager.play_sfx("hover_pause_button")


func _on_PauseButton_button_down():
	if not $UI/PauseButton.disabled:
		AudioManager.play_sfx("click_pause_button")


func _on_button_mouse_entered(button):
	if not button.disabled:
		AudioManager.play_sfx("hover_menu_button")


func _on_ContinueButton_pressed():
	start_game(true)


func _on_CompendiumButton_pressed():
	AudioManager.play_sfx("open_compendium")
	hover_compendium = false
	$RecipeCompendium.open()
	$UI/PauseButton.hide()
	$CompendiumButton.hide()


func _on_RecipeCompendium_closed():
	AudioManager.play_sfx("close_compendium")
	$UI/PauseButton.show()
	$CompendiumButton.show()


func _on_CompendiumButton_mouse_entered():
	if not $CompendiumButton.disabled:
		AudioManager.play_sfx("hover_compendium")
		hover_compendium = true


func _on_CompendiumButton_mouse_exited():
	hover_compendium = false


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_SheenTimer_timeout():
	sheen_tween.interpolate_property(sheen_material, "shader_param/shine_location", 0.0, 1.0, SHEEN_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sheen_tween.start()
	yield(sheen_tween, "tween_completed")
	sheen_material.set_shader_param("shine_location", 0.0)


func _on_Popup_Back_pressed():
	AudioManager.play_sfx("click")
	$PopupBG.hide()


func _on_Popup_Confirm_pressed():
	AudioManager.play_sfx("click")
	start_game(false)


func _on_growing_button_mouse_entered(which:String):
	is_hovered[which] = true


func _on_growing_button_mouse_exited(which:String):
	is_hovered[which] = false


func _on_Discord_pressed():
	AudioManager.play_sfx("click")
	var err = OS.shell_open("https://discord.gg/PqRRHVk39B")
	if err != OK:
		push_error("Error trying to open Discord page: " + str(err))


func _on_Steam_pressed():
	AudioManager.play_sfx("click")
	var err = OS.shell_open("https://store.steampowered.com/app/1960330/Alchemia_Creatio_Ex_Nihilo/")
	if err != OK:
		push_error("Error trying to open Steam page: " + str(err))


func _on_Updates_pressed():
	AudioManager.play_sfx("click")
	var err = OS.shell_open("https://store.steampowered.com/news/app/1960330?updates=true")
	if err != OK:
		push_error("Error trying to open Updates page: " + str(err))
