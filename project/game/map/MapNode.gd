extends Control
class_name MapNode

signal pressed

onready var button = $Button

enum {EMPTY, ENEMY, ELITE, BOSS, SHOP, REST, SMITH, EVENT}

const IMAGES = [preload("res://assets/images/map/elementCircle.png"),
		preload("res://assets/images/map/slime.png"),
		preload("res://assets/images/map/elite-slime.png"),
		preload("res://assets/images/map/skull.png"),
		preload("res://assets/images/map/coin.png"),
		preload("res://assets/images/map/fire-zone.png"),
		preload("res://assets/images/map/anvil-impact.png"),
		preload("res://assets/images/map/anvil-impact.png")]

var encounter : Encounter
var is_leaf := true
var map_tree_children := []
var map_lines := []
var paths_revealed := false
var type := EMPTY


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
	return type == EMPTY or type == SHOP or type == REST or type == SMITH


func _on_Button_pressed():
	emit_signal("pressed")
