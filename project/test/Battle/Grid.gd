extends Control

const GRIDSLOT = preload("res://test/Battle/GridSlot.tscn")

onready var Grid = $GridContainer

func _ready():
	setGrid(3)


func setGrid(size):
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = size
	for i in range(size*size):
		Grid.add_child(GRIDSLOT.instance())
		
