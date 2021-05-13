extends CanvasLayer

func _ready():
	pass


func set_player(p: Player):
	$BG/EndgameStats.set_player(p)


func _on_Button_pressed():
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")
