extends Control

onready var xp_pool_amount_label = $XPPool/Amount

func _ready():
	set_xp_pool(0)


func set_xp_pool(value):
	xp_pool_amount_label.text = str(value)


func get_available_xp():
	return int(xp_pool_amount_label)
