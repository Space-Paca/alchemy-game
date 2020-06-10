extends TextureRect

func _ready():
	AudioManager.play_bgm("menu")

# (❁´◡`❁)

func _on_NewGameButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/dungeon/Dungeon.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
