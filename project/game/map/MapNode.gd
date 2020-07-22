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

var is_leaf := true
var type := EMPTY
var map_tree_children := []
var map_lines := []


func set_type(new_type:int):
	if new_type == type:
		return
	
	type = new_type
	button.texture_normal = IMAGES[type]
	button.disabled = type == EMPTY


func should_autoreveal() -> bool:
	return type == EMPTY or type == SHOP or type == REST or type == SMITH


func _on_Button_pressed():
	emit_signal("pressed")
