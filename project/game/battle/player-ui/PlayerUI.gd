extends Node2D

onready var health_bar = $HealthBar


func set_life(max_hp, hp):
	health_bar.max_value = max_hp
	health_bar.value = hp

func take_damage(value):
	value = min(health_bar.value, value)
	health_bar.value -= value
	update_effects()

func heal(value):
	value = min(health_bar.max_value - health_bar.value, value)
	health_bar.value += value
	update_effects()

func update_effects():
	#Add more visual effects here later
	update_audio()

func update_audio():
	var percent = health_bar.value / float(health_bar.max_value)
	if percent > .5:
		AudioManager.play_bgm_layer(2)
		AudioManager.play_bgm_layer(3)
		AudioManager.remove_bgm_effect()
	elif  percent > .15:
		AudioManager.play_bgm_layer(2)
		AudioManager.stop_bgm_layer(3)
		AudioManager.start_bgm_effect("danger")
	else:
		AudioManager.stop_bgm_layer(2)
		AudioManager.stop_bgm_layer(3)
		AudioManager.start_bgm_effect("extreme-danger")
