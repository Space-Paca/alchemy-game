extends Node2D

tool

const HEALTH_BAR_MARGIN = 20

var type
var damage

func get_hp():
	return $HealthBar.value

func set_max_hp(hp):
	damage = 0
	$HealthBar.max_value = hp
	$HealthBar.value = hp
	
func set_image(new_texture):
	$TextureRect.texture = new_texture
	var w = get_width()
	var h = get_height()
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN

func get_width():
	return $TextureRect.rect_size.x

func get_height():
	return $TextureRect.rect_size.y
