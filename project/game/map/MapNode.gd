extends Control
class_name MapNode

signal pressed

onready var button = $Button
onready var legend = $Legend

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
		preload("res://assets/images/map/eventos.png"),
		preload("res://assets/images/map/laboratory.png"),
		preload("res://assets/images/map/treasure.png")]
const LEGEND = ["", "Enemy encounter", "Elite encounter", "Boss encounter",
		"Shop", "Rest area", "Reagent smith", "Event", "Laboratory", "Treasure"]

var encounter : Encounter
var is_leaf := true
var map_tree_children := []
var map_lines := []
var paths_revealed := false
var type := EMPTY
var mouse_over = false

func _process(dt):
	if mouse_over and type != EMPTY:
		$Legend.modulate.a = min($Legend.modulate.a + ALPHA_SPEED*dt, 1)
		$Button.rect_scale.x = min($Button.rect_scale.x + SCALE_SPEED*dt, TARGET_SCALE)
		$Button.rect_scale.y = min($Button.rect_scale.y + SCALE_SPEED*dt, TARGET_SCALE)
	else:
		$Legend.modulate.a = max($Legend.modulate.a - ALPHA_SPEED*dt, 0)
		$Button.rect_scale.x = max($Button.rect_scale.x - SCALE_SPEED*dt, 1)
		$Button.rect_scale.y = max($Button.rect_scale.y - SCALE_SPEED*dt, 1)
		

func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1),
								.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

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
	
	legend.text = LEGEND[type]


func should_autoreveal() -> bool:
	return type == EMPTY or type == SHOP or type == REST or type == SMITH or \
		   type == LABORATORY or type == TREASURE


func _on_Button_pressed():
	mouse_over = false
	emit_signal("pressed")


func _on_Button_mouse_entered():
	mouse_over = true


func _on_Button_mouse_exited():
	mouse_over = false
