extends Control

onready var anim = $AnimationPlayer
onready var sheen_tween = $Title/TitleSheen/Tween
onready var sheen_timer = $Title/TitleSheen/SheenTimer
onready var sheen_material = $Title/TitleSheen.material
onready var compendium_button = $CompendiumButton
onready var buttons = [$ContinueButton, $NewGameButton, $QuitButton]

const ALPHA_SPEED = 6
const SHEEN_DUR = .8
const SHEEN_INTERVAL = 5.0
const BGM_STOP_SPEED = 7.0

var hover_compendium = false

func _ready():
	
	anim.play("reset")
	sheen_timer.wait_time = SHEEN_INTERVAL
	
	for button in buttons:
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
# (❁´◡`❁)


func _process(dt):
	var label = $CompendiumButton/Label
	if hover_compendium:
		label.modulate.a = min(label.modulate.a + ALPHA_SPEED*dt, 1.0)
	else:
		label.modulate.a = max(label.modulate.a - ALPHA_SPEED*dt, 0.0)


func _input(event):
	if anim.is_playing() and (event.is_action_pressed("left_mouse_button") or \
			event.is_action_pressed("quit")):
		skip_intro_animation()
	
	if $QuitConfirm.visible and event.is_action_pressed("quit") :
		 $PauseScreen.toggle_pause()#Toggle pause again so it actually doesn't pauses
	elif event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		Profile.set_option("fullscreen", OS.window_fullscreen)
		if not OS.window_fullscreen:
			yield(get_tree(), "idle_frame")
			OS.window_size = Profile.WINDOW_SIZES[Profile.get_option("window_size")]


func skip_intro_animation():
	anim.seek(anim.get_animation("intro").length, true)
	for button in buttons:
		button.disabled = true
	yield(get_tree(), "idle_frame")
	for button in buttons:
		button.disabled = false


func start_game(continue_save := false):
	FileManager.continue_game = continue_save
	AudioManager.stop_bgm(BGM_STOP_SPEED)
	AudioManager.play_sfx("start_new_game")
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


func _on_NewGameButton_pressed():
	if FileManager.run_file_exists():
		$PopupBG.show()
	else:
		start_game()


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
	start_game()
