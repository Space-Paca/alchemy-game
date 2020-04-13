extends Node2D

onready var health_bar = $HealthBar


func set_health(value):
	health_bar.value = value
