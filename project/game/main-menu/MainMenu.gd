extends TextureRect

func _ready():
	AudioManager.play_bgm("menu")
	Debug.set_version_visible(true)
	
	FileManager.load_game()
# (❁´◡`❁)

func _input(event):
	if $QuitConfirm.visible and event.is_action_pressed("quit") :
		 $PauseScreen.toggle_pause()#Toggle pause again so it actually doesn't pauses
	elif event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		OS.window_borderless = OS.window_fullscreen


func _on_NewGameButton_pressed():
#	Debug.set_version_visible(false)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/dungeon/Dungeon.tscn")


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
