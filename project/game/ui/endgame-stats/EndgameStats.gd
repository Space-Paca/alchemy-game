extends Control

onready var menu_button = $Buttons/Menu
onready var restart_button = $Buttons/Restart

var player : Player


func _ready():
	pass


func set_player(p: Player):
	player = p
	$CompendiumProgress.set_player(p)


func progress_buttons_set_disabled(d: bool):
	menu_button.disabled = d
	restart_button.disabled = d


func _on_Menu_pressed():
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/main-menu/MainMenu.tscn")
	Transition.end_transition()

func _on_Restart_pressed():
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/dungeon/Dungeon.tscn")
	Transition.end_transition()


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")
