extends CanvasLayer

const GAME_OVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")

onready var tween = $Tween
onready var anim = $AnimationPlayer

var player

func _ready():
	AudioManager.play_bgm("gameover", false, true)
	$BG.modulate.a = 0
	$Thanks.modulate.a = 0
	$CheckBack.modulate.a = 0
	for child in $List.get_children():
		child.modulate.a = 0
	
	anim.play("enter")
	yield(anim, "animation_finished")
	
	yield(get_tree().create_timer(7), "timeout")
	
	tween.interpolate_property($FadeOut, "modulate:a", 0, 1, 2)
	tween.start()
	yield(tween, "tween_completed")
	
	var gameover = GAME_OVER_SCENE.instance()
	gameover.set_player(player)
	
	#Please Lord, forgive me for I have sinned; child, avert your eyes for the next line of code
	#May God have mercy on my soul
	get_parent().add_child(gameover)
	
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
	gameover.win_game()
	queue_free()
