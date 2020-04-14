extends Node2D

onready var health_bar = $HealthBar


func set_health(value):
	health_bar.value = value

func take_damage(value):
	value = min(health_bar.value, value)
	health_bar.value -= value

func heal(value):
	value = min(health_bar.max_value - health_bar.value, value)
	health_bar.value += value
