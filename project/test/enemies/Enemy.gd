extends Node2D

tool

signal acted

const HEALTH_BAR_MARGIN = 10

var type
var damage

func act():
	print("Attack!")
	$AnimationPlayer.play("attack")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	emit_signal("acted")

func get_hp():
	return $HealthBar.value
	

func set_max_hp(hp):
	damage = 0
	$HealthBar.max_value = hp
	$HealthBar.value = hp
	
func set_image(new_texture):
	$TextureRect.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN

func get_width():
	return $TextureRect.texture.get_width()

func get_height():
	return $TextureRect.texture.get_height()
