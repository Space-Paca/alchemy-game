extends TextureRect

onready var anim = $AnimationPlayer

const ALPHA_SPEED = 6

var hover_compendium = false

func _ready():
	FileManager.set_current_run(false)
	set_process_input(false)
	yield(get_tree(),"idle_frame")
	Transition.single_out_transition()
	AudioManager.play_bgm("menu")
	Debug.set_version_visible(true)
	$RecipeCompendium.hide()
	
	$ContinueButton.visible = FileManager.run_file_exists()
	
	yield(Transition, "finished")
	anim.play("intro")
	set_process_input(true)
# (❁´◡`❁)


func _process(dt):
	var label = $UI/CompendiumButton/Label
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


func _on_NewGameButton_pressed():
	AudioManager.play_sfx("start_new_game")
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


func _on_QuitButton_pressed():
	$QuitConfirm.show()


func _on_Yes_pressed():
	FileManager.save_and_quit()


func _on_No_pressed():
	$QuitConfirm.hide()


func _on_PauseButton_pressed():
	$PauseScreen.toggle_pause()


func _on_PauseButton_mouse_entered():
	AudioManager.play_sfx("hover_menu_button")


func _on_PauseButton_button_down():
	AudioManager.play_sfx("click_menu_button")


func _on_button_mouse_entered():
	AudioManager.play_sfx("hover_mainmenu_button")


func _on_ContinueButton_pressed():
	AudioManager.play_sfx("start_new_game")
	FileManager.continue_game = true
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


func _on_CompendiumButton_pressed():
	hover_compendium = false
	$RecipeCompendium.show()
	$UI/PauseButton.hide()
	$UI/CompendiumButton.hide()


func _on_RecipeCompendium_closed():
	$RecipeCompendium.hide()
	$UI/PauseButton.show()
	$UI/CompendiumButton.show()


func _on_CompendiumButton_mouse_entered():
	hover_compendium = true


func _on_CompendiumButton_mouse_exited():
	hover_compendium = false
