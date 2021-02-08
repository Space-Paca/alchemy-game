extends TextureRect

onready var anim = $AnimationPlayer

func _ready():
	set_process_input(false)
	yield(get_tree(),"idle_frame")
	Transition.single_out_transition()
	AudioManager.play_bgm("menu")
	Debug.set_version_visible(true)
	
	FileManager.load_game()
	
	yield(Transition, "finished")
	anim.play("intro")
	set_process_input(true)
# (❁´◡`❁)

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

