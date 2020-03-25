extends Node
class_name Combination

var c_grid_size : int
var c_name : String
var matrix : Array

func _ready():
	pass


func create_from_recipe(recipe: Recipe):
	c_grid_size = recipe.grid_size
	c_name = recipe.name
	var elements := (recipe.reagents.duplicate() as Array)
	
	for i in range(c_grid_size * c_grid_size - elements.size()):
		elements.append(null)
	
	elements.shuffle()
	
	for i in range(c_grid_size):
		var line = []
		for j in range(c_grid_size):
			line.append(elements.pop_front())
		
		matrix.append(line)
