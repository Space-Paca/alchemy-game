extends Control
class_name MapNode

signal pressed

onready var button = $Button

enum {EMPTY, ENEMY, ELITE, BOSS, SHOP, REST, SMITH, EVENT, LABORATORY, TREASURE}

const ALPHA_SPEED = 6
const SCALE_SPEED = 3
const TARGET_SCALE = 1.2

const IMAGES = [preload("res://assets/images/map/elementCircle.png"),
		preload("res://assets/images/map/enemy.png"),
		preload("res://assets/images/map/elite.png"),
		preload("res://assets/images/map/boss-open2.png"),
		preload("res://assets/images/map/shop.png"),
		preload("res://assets/images/map/descanso.png"),
		preload("res://assets/images/map/smith.png"),
		preload("res://assets/images/map/event.png"),
		preload("res://assets/images/map/laboratory.png"),
		preload("res://assets/images/map/treasure.png")]
const LEGEND = ["", "Enemy", "Elite", "Boss",
		"Shop", "Rest", "Reagent Smith", "Event", "Laboratory", "Treasure"]

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
	randomize()
	$Light2D.rotation = rand_range(0, 360)
	$Light2D.texture_scale = rand_range(1.8, 2.7)


func _process(dt):
	if mouse_over and type != EMPTY:
		$Button.rect_scale.x = min($Button.rect_scale.x + SCALE_SPEED*dt, TARGET_SCALE)
		$Button.rect_scale.y = min($Button.rect_scale.y + SCALE_SPEED*dt, TARGET_SCALE)
	else:
		$Button.rect_scale.x = max($Button.rect_scale.x - SCALE_SPEED*dt, 1)
		$Button.rect_scale.y = max($Button.rect_scale.y - SCALE_SPEED*dt, 1)


func disable_tooltips():
	remove_tooltips()
	$TooltipCollision.disable()


func enable_tooltips():
	$TooltipCollision.enable()


func get_alpha():
	return modulate.a


func fade_in():
	var dur = .5
	$Light2D.mode = Light2D.MODE_ADD
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1),
								dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Light2D, "energy", 0.01, .3,
							dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	is_revealed = true
	yield(get_tree().create_timer(dur), "timeout")
	$Light2D.energy = .8
	$Light2D.mode = Light2D.MODE_MIX
	$Tween.interpolate_property($Light2D, "energy", $Light2D.energy, 1,
							.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func set_camera(cam):
	camera = cam


func set_type(new_type:int):
	if new_type == type:
		return
	
	type = new_type
	button.texture_normal = IMAGES[type]
	button.disabled = type == EMPTY
	
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
			   "title_image": IMAGES[type], "subtitle": "Location"}
	return tooltip


func _on_Button_pressed():
	mouse_over = false
	emit_signal("pressed")


func _on_Button_mouse_entered():
	mouse_over = true


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
