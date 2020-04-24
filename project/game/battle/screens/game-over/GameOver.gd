extends CanvasLayer

func _ready():
	pass


func _on_Button_pressed():
	AudioManager.play_sfx("click")
	var _err = get_tree().change_scene("res://game/dungeon/Dungeon.tscn")
