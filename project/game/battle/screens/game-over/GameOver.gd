extends CanvasLayer

func _ready():
	pass


func _on_Button_pressed():
	var _err = get_tree().change_scene("res://game/dungeon/Dungeon.tscn")

func _on_Button_button_down():
	AudioManager.play_sfx("click")

func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")
