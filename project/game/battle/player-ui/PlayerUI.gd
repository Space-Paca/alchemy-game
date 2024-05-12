tool
extends Node2D

signal animation_completed

const ARTIFACT = preload("res://game/ui/Artifact.tscn")

onready var health_bar = $HealthBar
onready var portrait = $Portrait

func _ready():
	for artifact in $Artifacts.get_children():
		$Artifacts.remove_child(artifact)
	portrait.set_battle_mode()


func set_player(player):
	portrait.set_player(player)


func enable_tooltips():
	$StatusBar.enable()
	for artifact in $Artifacts.get_children():
		artifact.enable()

func disable_tooltips():
	$StatusBar.disable()
	for artifact in $Artifacts.get_children():
		artifact.disable()


func update_max_hp(value):
	health_bar.update_max_hp(value)


func set_life(max_hp, hp):
	health_bar.set_life(hp, max_hp)

func dummy_rising_number():
	health_bar.dummy_rising_number()
	yield(health_bar, "animation_completed")
	emit_signal("animation_completed")


func need_to_update_visuals(player):
	return health_bar.need_to_update(player.hp, player.shield)


func update_visuals(player):
	if health_bar.need_to_update(player.hp, player.shield):
		update_audio(player.hp, player.max_hp)
		update_portrait(player.hp, player.max_hp)
		health_bar.update_visuals(player.hp, player.shield)
		yield(health_bar, "animation_completed")
		emit_signal("animation_completed")

func update_artifacts(player):
	for artifact in $Artifacts.get_children():
		$Artifacts.remove_child(artifact)
	
	for artifact_name in player.get_artifacts():
		var artifact = ARTIFACT.instance()
		$Artifacts.add_child(artifact)
		artifact.init(artifact_name)
	
	yield(get_tree(), "idle_frame")
	for artifact in $Artifacts.get_children():
		artifact.update_size(1.0)

func update_status_bar(player):
	$StatusBar.clean_removed_status(player.status_list)
	var status_type = player.status_list.keys();
	for type in status_type:
		var status = player.status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)


func update_audio(hp, max_hp):
	var percent = hp / float(max_hp)
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
		return

func update_portrait(hp, max_hp):
	portrait.update_visuals(hp, max_hp)

#Returns the global position of the center of portrait
func get_animation_position():
	return $AnimationPosition.global_position


func play_damage_animation(damage: int):
	if damage < 10:
		portrait.play_animation("weak_damage")
	elif damage < 20:
		portrait.play_animation("average_damage")
	else:
		portrait.play_animation("strong_damage")
