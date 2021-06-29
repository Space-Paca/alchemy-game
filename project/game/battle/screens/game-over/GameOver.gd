extends CanvasLayer

onready var tween = $Tween


func _ready():
	pass


func set_player(p: Player):
	$BG/EndgameStats.set_player(p)


func animate_book():
	yield(get_tree().create_timer(1.5), "timeout")
	tween.interpolate_property($BG/EndgameStats, "rect_position:y", null, 0, 1.5,
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
	animate_book()
