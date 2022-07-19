extends CanvasLayer

const GAME_OVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")

var player

func _ready():
	AudioManager.play_bgm("demo_ending", false, true)


func show_gameover():
	var gameover = GAME_OVER_SCENE.instance()
	gameover.set_player(player)
	
	#Please Lord, forgive me for I have sinned; child, avert your eyes for the next line of code
	#May God have mercy on my soul
	get_parent().add_child(gameover)
	# (╯°□°）╯︵ ┻━┻
	
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
	gameover.win_game()
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "ending":
		return
	
	show_gameover()
