tool
extends Character

signal acted

const HEALTH_BAR_MARGIN = 10

func act():
	print("Attack!")
	$AnimationPlayer.play("attack")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	emit_signal("acted")

func setup(new_texture):
	set_max_hp()
	set_image(new_texture)
	
func set_max_hp():
	$HealthBar.max_value = max_hp
	$HealthBar.value = max_hp
	
func set_image(new_texture):
	$TextureRect.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN

func get_width():
	return $TextureRect.rect_size.x

func get_height():
	return $TextureRect.rect_size.y
