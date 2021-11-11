extends Control
class_name MapNode

signal pressed

onready var button = $Button

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
	$HoverSFX.volume_db = MUTE_DB
	randomize()
	$Light2D.rotation = rand_range(0, 360)
	$Light2D.texture_scale = rand_range(1.8, 2.7)
	if Profile.get_option("disable_map_fog"):
		disable_lights()
	else:
		enable_lights()


func _process(dt):
	if mouse_over and type != EMPTY:
		$Button.rect_scale.x = min($Button.rect_scale.x + SCALE_SPEED*dt, TARGET_SCALE)
		$Button.rect_scale.y = min($Button.rect_scale.y + SCALE_SPEED*dt, TARGET_SCALE)
		$HoverSFX.volume_db = min($HoverSFX.volume_db + SFX_SPEED*dt, 0.0)
	else:
		$Button.rect_scale.x = max($Button.rect_scale.x - SCALE_SPEED*dt, 1)
		$Button.rect_scale.y = max($Button.rect_scale.y - SCALE_SPEED*dt, 1)
		$HoverSFX.volume_db = max($HoverSFX.volume_db - 1.7*SFX_SPEED*dt, MUTE_DB)
	
	if $HoverSFX.stream:
		if $HoverSFX.volume_db > MUTE_DB and not $HoverSFX.playing:
			$HoverSFX.play(rand_range(0.0, $HoverSFX.stream.get_length()))
		elif $HoverSFX.volume_db <= MUTE_DB:
			$HoverSFX.stop()

func enable_lights():
	$Light2D.enabled = true


func disable_lights():
	$Light2D.enabled = false


func disable_tooltips():
	$Button.disabled = true
	remove_tooltips()
	$TooltipCollision.disable()


func enable_tooltips():
	$Button.disabled = type == EMPTY and true or false
	$TooltipCollision.enable()


func get_alpha():
	return modulate.a


func light_up():
	var dur = .5
	$Tween.interpolate_property($Light2D, "energy", 0.5, 1,
							dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	is_revealed = true


func fade_in():
	var offset = .8
	var dur = LIGHT_UP_DUR + rand_range(-offset, offset)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1),
								dur/3.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Light2D, "energy", 0.5, 1,
							dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property($Light2D, "scale", Vector2(0,0), Vector2(1,1),
							dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	AudioManager.play_sfx("map_expand")
	is_revealed = true
	if type == BOSS:
		$AnimationPlayer.play("BossIntro")


func set_camera(cam):
	camera = cam


func set_type(new_type:int):
	if new_type == type:
		return
	
	type = new_type
	
	if type == BOSS:
		button.texture_normal = BOSS_IMAGES[0]
	else:
		button.texture_normal = IMAGES[type]
	if SFXS[type]:
		$HoverSFX.stream = SFXS[type]
	
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
	mouse_over = true
	if type != EMPTY and not button.disabled:
		AudioManager.play_sfx("hover_map_node")

func _on_Button_mouse_exited():
	mouse_over = false


func _on_TooltipCollision_enable_tooltip():
	if type == EMPTY:
		return
	
	tooltips_enabled = true
	var tooltip = get_node_tooltip()
	TooltipLayer.add_tooltip($TooltipCollision.get_position() - camera.get_offset(), \
							tooltip.title, tooltip.text, tooltip.title_image, tooltip.subtitle, true)


func _on_TooltipCollision_disable_tooltip():
	remove_tooltips()
