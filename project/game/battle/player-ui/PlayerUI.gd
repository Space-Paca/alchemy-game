extends Node2D

onready var health_bar = $HealthBar


func set_life(max_hp, hp):
	health_bar.max_value = max_hp
	health_bar.value = hp

func take_damage(value):
	value = min(health_bar.value, value)
	health_bar.value -= value

func heal(value):
	value = min(health_bar.max_value - health_bar.value, value)
	health_bar.value += value
