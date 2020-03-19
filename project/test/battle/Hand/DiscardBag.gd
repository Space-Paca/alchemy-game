extends Node2D

var Reagents = null #Setted by parent

func _ready():
	$Center.position = $TextureRect.rect_size/2

func get_center():
	return $Center.global_position

func discard(reagent):
	reagent.slot = null
	reagent.target_position = get_center()
	reagent.can_drag = false
	
