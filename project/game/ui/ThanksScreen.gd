extends CanvasLayer

onready var shake = $ShakeVar
onready var subtitles = $SubtitleContainer/Subtitles
onready var tween = $Tween
onready var progress = $Skip/HBoxContainer/TextureProgress
onready var skip = $Skip
onready var skip_timer = $SkipShowTimer

const GAME_OVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")
const SUBTITLE_FADE_DURATION = .5
const ENDING_TEXT = [
	"ENDING_TEXT_1",
	"ENDING_TEXT_2",
	"ENDING_TEXT_3",
	"ENDING_TEXT_4",
]
const FILL_SPEED = 1
const UNFILL_SPEED = 2
const SKIP_HIDE_SPEED = 1


var player
var shaking := true
var showing_gameover := false
var time := .0
var skip_enabled := false

func _ready():
	AudioManager.play_bgm("demo_ending", false, true)


func _input(event):
	if ((event is InputEventKey and event.pressed) or\
			event.is_action_pressed("left_mouse_button")) and\
			skip_timer.is_stopped() and skip_enabled:
		skip_timer.start()
		skip.modulate.a = 1
	
	get_tree().set_input_as_handled()


func _process(delta):
	if shaking:
		ShakeCam.set_continuous_shake(shake.position.x, ShakeCam.MAX_PRIO)
	
	if Input.is_action_pressed("quit") and skip_enabled:
		progress.value = clamp(progress.value + FILL_SPEED * delta, 0, 1)
	else:
		progress.value = clamp(progress.value - UNFILL_SPEED * delta, 0, 1)
	
	if progress.value == 1:
		set_process(false)
		show_gameover()
	elif skip_timer.is_stopped() and progress.value == 0:
		skip.modulate.a -= SKIP_HIDE_SPEED * delta


func end_shake():
	ShakeCam.set_continuous_shake(0, ShakeCam.MAX_PRIO)
	shaking = false


func enable_skip():
	skip_enabled = true


func show_subtitle_text(index: int, duration: float):
	subtitles.text = ENDING_TEXT[index]
	
	tween.interpolate_property(subtitles, "modulate:a", 0, 1,
			SUBTITLE_FADE_DURATION)
	tween.start()
	
	yield(get_tree().create_timer(duration), "timeout")
	
	tween.interpolate_property(subtitles, "modulate:a", 1, 0,
			SUBTITLE_FADE_DURATION)
	tween.start()


func show_gameover():
	if showing_gameover:
		return
	showing_gameover = true
	
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
