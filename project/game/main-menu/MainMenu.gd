extends TextureRect

onready var anim = $AnimationPlayer
onready var compendium_button = $CompendiumButton
onready var buttons = [$ContinueButton, $NewGameButton, $QuitButton]

const ALPHA_SPEED = 6

var hover_compendium = false

func _ready():
	anim.play("reset")
	
	for button in buttons:
		button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
	FileManager.set_current_run(false)
	set_process_input(false)
	compendium_button.visible = UnlockManager.is_misc_unlocked("COMPENDIUM")
	
	yield(get_tree(),"idle_frame")
	
	AudioManager.play_bgm("menu")
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
		OS.window_borderless = OS.window_fullscreen


func skip_intro_animation():
	anim.seek(anim.get_animation("intro").length, true)
	for button in buttons:
		button.disabled = true
	yield(get_tree(), "idle_frame")
	for button in buttons:
		button.disabled = false


func _on_NewGameButton_pressed():
	AudioManager.play_sfx("start_new_game")
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


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
	AudioManager.play_sfx("start_new_game")
	FileManager.continue_game = true
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


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


func _on_Yes_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_No_mouse_entered():
	AudioManager.play_sfx("hover_button")
