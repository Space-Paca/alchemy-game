extends Control


func _ready():
	yield(get_tree(), "idle_frame")
	yield(get_tree().create_timer(1.0), "timeout")
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")
