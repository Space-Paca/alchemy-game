extends CanvasLayer

onready var tween = $Tween
onready var anim = $AnimationPlayer

func _ready():
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
	
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")
