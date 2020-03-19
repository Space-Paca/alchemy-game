tool
extends Node2D

const HANDSLOT = preload("res://test/Battle/Hand/HandSlot.tscn")

export var size = 10

onready var Grid = $GridContainer
onready var BG = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	setHand(8)


func setHand(slots):
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = slots/2
	for i in range(slots):
		Grid.add_child(HANDSLOT.instance())
	BG.size.x = Grid.get_child(1).size.x * size/2
