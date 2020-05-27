tool
extends Node2D

onready var health_bar = $HealthBar
onready var gold_label = $Gold/Label

func update_tooltip_pos():
	#Setup tooltip collision
	$TooltipCollision.position.x = (health_bar.rect_position.x + health_bar.rect_size.x)/2
	$TooltipCollision.position.y = $Portrait.rect_size.y * $Portrait.rect_scale.y/2
	var w = health_bar.rect_position.x + health_bar.rect_size.x
	var h = $Portrait.rect_size.y * $Portrait.rect_scale.y
	$TooltipCollision.set_collision_shape(Vector2(w, h))
	

func set_life(max_hp, hp):
	health_bar.set_life(hp, max_hp)


func set_gold(amount: int):
	gold_label.text = str(amount)


func update_life(player):
	health_bar.update_life(player.hp)
	update_effects()

func update_effects():
	update_audio()

func update_shield(player):
	health_bar.update_shield(player.shield)

func update_status_bar(player):
	$StatusBar.clean_removed_status(player.status_list)
	var status_type = player.status_list.keys();
	for type in status_type:
		var status = player.status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)

func update_audio():
	var percent = health_bar.get_percent()
	if percent > .5:
		AudioManager.update_bgm_layers([true, true, true])
		AudioManager.stop_aux_bgm("heart-beat")
		AudioManager.remove_bgm_effect()
	elif percent > .2:
		AudioManager.update_bgm_layers([true, true, false])
		AudioManager.stop_aux_bgm("heart-beat")
		AudioManager.start_bgm_effect("danger")
	elif percent > .0:
		AudioManager.update_bgm_layers([true, false, false])
		AudioManager.play_aux_bgm("heart-beat")
		AudioManager.start_bgm_effect("extreme-danger")
	else:
		AudioManager.stop_bgm_layer(2)
		AudioManager.stop_bgm_layer(3)
		AudioManager.stop_aux_bgm("heart-beat")
		AudioManager.start_bgm_effect("extreme-danger")

#Returns the global position of the center of portrait
func get_animation_position():
	return $AnimationPosition.global_position

func get_tooltips():
	var tooltips = []
	
	#Get status tooltips
	for tooltip in $StatusBar.get_status_tooltips():
		tooltips.append(tooltip)

	return tooltips

func _on_TooltipCollision_disable_tooltip():
	TooltipLayer.clean_tooltips()

func _on_TooltipCollision_enable_tooltip():
	var play_sfx = true
	for tooltip in get_tooltips():
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
								 tooltip.text, tooltip.title_image, play_sfx)
		play_sfx = false
