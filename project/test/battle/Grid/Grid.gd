tool

extends Control

const GRIDSLOT = preload("res://test/Battle/Grid/GridSlot.tscn")
const MARGIN = 30

onready var Grid = $GridContainer
onready var RecipeButton = $CreateRecipe 

func _ready():
	set_grid(3)


func set_grid(size):
	assert(size > 0)
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = size
	for _i in range(size*size):
		Grid.add_child(GRIDSLOT.instance())
	var slot = Grid.get_child(1)
	
	#Position button correctly
	var scale = RecipeButton.rect_scale.x
	RecipeButton.rect_position.y = slot.rect_size.y * size + MARGIN
	RecipeButton.rect_position.x = slot.rect_size.x*size/2 - RecipeButton.rect_size.x*scale/2
	
