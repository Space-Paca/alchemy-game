extends CanvasLayer

onready var tween = $Tween


func _ready():
	$BG.hide()
	$BG/BG2.visible = randi()%2
	var mod = 2.0 if Profile.get_option("turbo_mode") else 1.0
	$AnimationPlayer.playback_speed = mod

func set_player(p: Player):
	$BG/EndgameStats.set_player(p)


func win_game():
	$AnimationPlayer.stop()
	$BG.show()
	Transition.end_transition()
	yield(Transition, "finished")
	var dur = .8 if Profile.get_option("turbo_mode") else 1.5
	yield(get_tree().create_timer(dur), "timeout")
	animate_book()

func animate_book():
	var dur = .5 if Profile.get_option("turbo_mode") else 1.5
	tween.interpolate_property($BG/EndgameStats, "rect_position:y", null, 0, dur,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	$BG/EndgameStats/Page1/RunStats.begin_animations()


func _on_AnimationPlayer_animation_finished(_anim_name):
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
	$BG.show()
	Transition.end_transition()
	yield(Transition, "finished")
	var dur = .5 if Profile.get_option("turbo_mode") else 1.5
	yield(get_tree().create_timer(dur), "timeout")
	animate_book()
