tool
extends Node2D

const HANDSLOT = preload("res://test/Battle/Hand/HandSlot.tscn")
const H_MARGIN = 40
const V_MARGIN = 25

export var size = 10

onready var Grid = $GridContainer
onready var BG = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	Grid.rect_position = Vector2(H_MARGIN, V_MARGIN)
	set_hand(8)


func set_hand(slots):
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = slots/2
	for i in range(slots):
		Grid.add_child(HANDSLOT.instance())
	BG.rect_size.x = Grid.get_child(1).rect_size.x * slots/2 + 2*V_MARGIN
	BG.rect_size.y = Grid.get_child(1).rect_size.y * 2 + 2*V_MARGIN
