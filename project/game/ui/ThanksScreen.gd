extends CanvasLayer

onready var tween = $Tween

func _ready():
	$BG.modulate.a = 0
	$Thanks.modulate.a = 0
	$CheckBack.modulate.a = 0
	
	tween.interpolate_property($BG, "modulate:a", 0, 1, 1.5)
	tween.start()
	yield(tween, "tween_completed")
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	tween.interpolate_property($Thanks, "modulate:a", 0, 1, 1.5)
	tween.start()
	yield(tween, "tween_completed")
	
	yield(get_tree().create_timer(3.5), "timeout")
	
	tween.interpolate_property($CheckBack, "modulate:a", 0, 1, 1.5)
	tween.start()
	yield(tween, "tween_completed")
	
	
	yield(get_tree().create_timer(8.5), "timeout")
	
	tween.interpolate_property($FadeOut, "modulate:a", 0, 1, 2)
	tween.start()
	yield(tween, "tween_completed")
	
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")
