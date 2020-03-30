extends Node
class_name Combination

var grid_size : int
var recipe_name : String
var matrix : Array

func _ready():
	pass


func create_from_recipe(recipe: Recipe):
	grid_size = recipe.grid_size
	recipe_name = recipe.name
	var avaiable_positions := []
	var elements := (recipe.reagents.duplicate() as Array)
	elements.shuffle()
	
	for i in range(grid_size):
		var line = []
		for j in range(grid_size):
			line.append(null)
			avaiable_positions.append([i, j])
		matrix.append(line)
	
	# Placing the first two reagents that guarantee grid size consistency
	var pos1 : Array
	var pos2 : Array
	if randf() < .5:
		pos1 = [0, randi() % grid_size]
		pos2 = [grid_size - 1, randi() % grid_size]
	else:
		pos1 = [randi() % grid_size, 0]
		pos2 = [randi() % grid_size, grid_size - 1]
	matrix[pos1[0]][pos1[1]] = elements.pop_front()
	matrix[pos2[0]][pos2[1]] = elements.pop_front()
	avaiable_positions.erase(pos1)
	avaiable_positions.erase(pos2)
	
	# Placing the rest
	avaiable_positions.shuffle()
	while not elements.empty():
		var pos = avaiable_positions.pop_front()
		matrix[pos[0]][pos[1]] = elements.pop_front()
