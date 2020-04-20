extends CanvasLayer

func _ready():
	pass


func _on_Button_pressed():
	var _err = get_tree().change_scene("res://game/dungeon/Dungeon.tscn")
