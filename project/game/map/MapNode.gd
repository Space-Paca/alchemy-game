extends Control
class_name MapNode

onready var button = $Button

enum {EMPTY, ENEMY, ELITE, BOSS, SHOP, REST, SMITH}

const IMAGES = [preload("res://assets/images/map/elementCircle.png"),
		preload("res://assets/images/map/slime.png"),
		preload("res://assets/images/map/elite-slime.png"),
		preload("res://assets/images/map/skull.png"),
		preload("res://assets/images/map/coin.png"),
		preload("res://assets/images/map/fire-zone.png"),
		preload("res://assets/images/map/anvil-impact.png")]

var is_leaf := true
var type := EMPTY


func _ready():
	pass


func set_type(new_type:int):
	if new_type == type:
		return
	
	type = new_type
	button.texture_normal = IMAGES[type]
	button.disabled = type == EMPTY
