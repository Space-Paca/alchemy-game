extends Control
class_name MapNode

signal pressed

onready var button = $Button
onready var hover_sfx = $HoverSFX
onready var light = $Light2D

enum {EMPTY, ENEMY, ELITE, BOSS, SHOP, REST, SMITH, EVENT, LABORATORY, TREASURE}

const ALPHA_SPEED = 6
const SCALE_SPEED = 3
const TARGET_SCALE = 1.2
const LIGHT_UP_DUR = 2.972
const LIGHT_TEX = preload("res://assets/images/map/light_tex_2.png")
const IMAGES = [
		preload("res://assets/images/map/elementCircle.png"),
		preload("res://assets/images/map/enemy.png"),
		preload("res://assets/images/map/elite.png"),
		preload("res://assets/images/map/boss-open2.png"),
		preload("res://assets/images/map/shop.png"),
		preload("res://assets/images/map/descanso.png"),
		preload("res://assets/images/map/smith.png"),
		preload("res://assets/images/map/event.png"),
		preload("res://assets/images/map/laboratory.png"),
		preload("res://assets/images/map/treasure.png")]
const SFXS = [
		false,
		preload("res://assets/audio/sfx/normal_battle_icon_hover.wav"),
		preload("res://assets/audio/sfx/elite_battle_icon_hover.wav"),
		preload("res://assets/audio/sfx/boss_battle_icon_hover.wav"),
		preload("res://assets/audio/sfx/shop_icon_hover.wav"),
		preload("res://assets/audio/sfx/resting_circle_icon_hover.wav"),
		preload("res://assets/audio/sfx/blacksmith_icon_hover.wav"),
		preload("res://assets/audio/sfx/event_battle_icon_hover.wav"),
		preload("res://assets/audio/sfx/cauldron_icon_hover.wav"),
		preload("res://assets/audio/sfx/treasure_icon_hover.wav")
]
const MUTE_DB = -60
const SFX_SPEED = 40
const LEGEND = ["", "ENEMY", "ELITE", "BOSS",
		"SHOP", "RESTING_CIRCLE", "REAGENT_SMITH", "EVENT", "LABORATORY", "TREASURE"]

const BOSS_IMAGES = [
	preload("res://assets/images/map/boss-closed.png"),
	preload("res://assets/images/map/boss-open1.png"),
	preload("res://assets/images/map/boss-open2.png"),
]

var encounter : Encounter
var is_leaf := true
var map_tree_children := []
var map_lines := []
var paths_revealed := false
var is_revealed := false
var type := EMPTY
var mouse_over = false
var tooltips_enabled := false
var camera = null


func _ready():
	hover_sfx.volume_db = MUTE_DB
	randomize()
	light.rotation = rand_range(0, 360)
	light.texture_scale = rand_range(1.8, 2.7)
	if Profile.get_option("disable_map_fog"):
		disable_lights()
	else:
		enable_lights()


func _process(dt):
	if mouse_over and type != EMPTY:
		button.rect_scale.x = min(button.rect_scale.x + SCALE_SPEED*dt, TARGET_SCALE)
		button.rect_scale.y = min(button.rect_scale.y + SCALE_SPEED*dt, TARGET_SCALE)
		hover_sfx.volume_db = min(hover_sfx.volume_db + SFX_SPEED*dt, 0.0)
	else:
		button.rect_scale.x = max(button.rect_scale.x - SCALE_SPEED*dt, 1)
		button.rect_scale.y = max(button.rect_scale.y - SCALE_SPEED*dt, 1)
		hover_sfx.volume_db = max(hover_sfx.volume_db - 1.7*SFX_SPEED*dt, MUTE_DB)
	
	if hover_sfx.stream:
		if hover_sfx.volume_db > MUTE_DB and not hover_sfx.playing:
			hover_sfx.play(rand_range(0.0, hover_sfx.stream.get_length()))
		elif hover_sfx.volume_db <= MUTE_DB and hover_sfx.playing:
			hover_sfx.stop()


func enable_lights():
	light.enabled = true


func disable_lights():
	light.enabled = false


func disable_tooltips():
	$Button.disabled = true
	remove_tooltips()
	$TooltipCollision.disable()


func enable_tooltips():
	button.disabled = type == EMPTY and true or false
	$TooltipCollision.enable()


func get_alpha():
	return modulate.a


func light_up():
	var dur = .5
	$Tween.interpolate_property(light, "energy", 0.5, 1,
							dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	is_revealed = true
	yield($Tween, "tween_completed")
	animate_light()


func fade_in():
	var offset = .8
	var dur = LIGHT_UP_DUR + rand_range(-offset, offset)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1),
								dur/3.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(light, "energy", 0.5, 1,
							dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property(light, "scale", Vector2(0,0), Vector2(1,1),
							dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	AudioManager.play_sfx("map_expand")
	is_revealed = true
	if type == BOSS:
		$AnimationPlayer.play("BossIntro")
	yield($Tween, "tween_all_completed")
	animate_light()


func animate_light():
	var anim = $Light2D/AnimationPlayer
	anim.play("moving", -1, rand_range(.5, .7))
	#anim.seek(rand_range(0.0, anim.current_animation_length), true)


func set_camera(cam):
	camera = cam


func set_type(new_type:int):
	if new_type == type:
		return
	
	type = new_type
	
	if type == BOSS:
		button.get_node("Sprite").texture = BOSS_IMAGES[0]
	else:
		button.get_node("Sprite").texture = IMAGES[type]
	if SFXS[type]:
		hover_sfx.stream = SFXS[type]
	
	if type == ENEMY:
		encounter = EncounterManager.get_random_encounter()
	elif type == ELITE:
		encounter = EncounterManager.get_random_elite_encounter()
	elif type == BOSS:
		encounter = EncounterManager.get_random_boss_encounter()


func should_autoreveal() -> bool:
	return type in [EMPTY, SHOP, REST, SMITH, LABORATORY, TREASURE]


func remove_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()


func get_node_tooltip():
	var tooltip = {}
	tooltip = {"title": LEGEND[type], "text": "", \
			   "title_image": IMAGES[type], "subtitle": "LOCATION"}
	return tooltip


func _on_Button_pressed():
	mouse_over = false
	emit_signal("pressed")


func _on_Button_mouse_entered():
	if type != EMPTY and not button.disabled:
		mouse_over = true
		AudioManager.play_sfx("hover_map_node")
		AudioManager.enable_bgm_filter_effect(-8, .8, self)

func _on_Button_mouse_exited():
	if type != EMPTY and not button.disabled:
		mouse_over = false
		AudioManager.disable_bgm_filter_effect(1.1, self)


func _on_TooltipCollision_enable_tooltip():
	if type == EMPTY:
		return
	
	tooltips_enabled = true
	var tooltip = get_node_tooltip()
	#This math is not ideal still, but for now it suffices
	var offset = Vector2(50, -40)
	var pos = $TooltipCollision.get_global_transform_with_canvas().origin + offset
	TooltipLayer.add_tooltip(pos, tooltip.title, tooltip.text, tooltip.title_image, tooltip.subtitle, true)


func _on_TooltipCollision_disable_tooltip():
	remove_tooltips()
