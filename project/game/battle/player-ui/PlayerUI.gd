tool
extends Node2D

onready var health_bar = $HealthBar

func _ready():
	$HealthBar/Shield.hide()

func update_tooltip_pos():
	#Setup tooltip collision
	$TooltipCollision.position.x = (health_bar.rect_position.x + health_bar.rect_size.x)/2
	$TooltipCollision.position.y = $Portrait.rect_size.y * $Portrait.rect_scale.y/2
	var w = health_bar.rect_position.x + health_bar.rect_size.x
	var h = $Portrait.rect_size.y * $Portrait.rect_scale.y
	$TooltipCollision.set_collision_shape(Vector2(w, h))
	

func set_life(max_hp, hp):
	health_bar.max_value = max_hp
	health_bar.value = hp
	$HealthBar/Label.text = str(hp) + "/" + str(max_hp)

func update_life(player):
	$HealthBar.value = player.hp
	$HealthBar/Label.text = str(player.hp) + "/" + str(player.max_hp)
	update_effects()

func update_effects():
	update_audio()

func update_shield(player):
	if player.shield > 0:
		$HealthBar/Shield.show()
		$HealthBar/Shield/Label.text = str(player.shield)
	else:
		$HealthBar/Shield.hide()

func update_status_bar(player):
	$StatusBar.clean_removed_status(player.status_list)
	var status_type = player.status_list.keys();
	for type in status_type:
		var status = player.status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)

func update_audio():
	var percent = health_bar.value / float(health_bar.max_value)
	if percent > .5:
		AudioManager.play_bgm_layer(2)
		AudioManager.play_bgm_layer(3)
		AudioManager.stop_aux_bgm()
		AudioManager.remove_bgm_effect()
	elif percent > .2:
		AudioManager.play_bgm_layer(2)
		AudioManager.stop_bgm_layer(3)
		AudioManager.stop_aux_bgm()
		AudioManager.start_bgm_effect("danger")
	else:
		AudioManager.stop_bgm_layer(2)
		AudioManager.stop_bgm_layer(3)
		AudioManager.play_aux_bgm("heart-beat")
		AudioManager.start_bgm_effect("extreme-danger")

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
