extends Control

const GRIDSLOT = preload("res://test/Battle/Grid/GridSlot.tscn")

onready var Grid = $GridContainer

func _ready():
	set_grid(3)


func set_grid(size):
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = size
	for _i in range(size*size):
		Grid.add_child(GRIDSLOT.instance())
		
