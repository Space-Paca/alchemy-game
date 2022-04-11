extends Node2D

export var spread_deg := 30.0


func _ready():
	$Poison.rotation_degrees = rand_range(-spread_deg, spread_deg)
