extends Control

signal continue_credits

const GAME_OVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")

var player


func set_player(p):
	player = p


func _on_Continue_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_Continue_pressed():
	emit_signal("continue_credits")
	var gameover = GAME_OVER_SCENE.instance()
	gameover.set_player(player)
	get_parent().add_child(gameover)
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
	gameover.win_game()
	queue_free()
