extends Control
class_name MapNode

signal pressed

onready var button = $Button
onready var legend = $Legend

enum {EMPTY, ENEMY, ELITE, BOSS, SHOP, REST, SMITH, EVENT}

const IMAGES = [preload("res://assets/images/map/elementCircle.png"),
		preload("res://assets/images/map/enemy.png"),
		preload("res://assets/images/map/elite.png"),
		preload("res://assets/images/map/boss-open2.png"),
		preload("res://assets/images/map/shop.png"),
		preload("res://assets/images/map/descanso.png"),
		preload("res://assets/images/map/reagents.png"),
		preload("res://assets/images/map/eventos.png")]
const LEGEND = ["", "Enemy encounter", "Elite encounter", "Boss encounter",
		"Shop", "Rest area", "Reagent smith", "Event"]

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
	
	legend.text = LEGEND[type]


func should_autoreveal() -> bool:
	return type == EMPTY or type == SHOP or type == REST or type == SMITH


func _on_Button_pressed():
	emit_signal("pressed")


func _on_Button_mouse_entered():
	$Legend.show()


func _on_Button_mouse_exited():
	$Legend.hide()
