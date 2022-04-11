extends Node2D

onready var hits = [$Hit1, $Hit2]

func _ready():
	var hit : Sprite = hits[randi()%2]
	hit.rotation_degrees = randf() * 360
	hit.show()
