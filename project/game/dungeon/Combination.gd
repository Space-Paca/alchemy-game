extends Node
class_name Combination

var grid_size : int
var recipe : Recipe
var matrix : Array
var known_matrix : Array


func create_from_recipe(_recipe: Recipe):
	recipe = _recipe
	grid_size = recipe.grid_size
	var available_positions := []
	var elements := (recipe.reagents.duplicate() as Array)
	elements.shuffle()
	
	for i in range(grid_size):
		var line = []
		var unknown_line = []
		for j in range(grid_size):
			line.append(null)
			unknown_line.append("unknown")
			available_positions.append([i, j])
		matrix.append(line)
		known_matrix.append(unknown_line)
	
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
	available_positions.erase(pos1)
	available_positions.erase(pos2)
	
	# Placing the rest
	available_positions.shuffle()
	while not elements.empty():
		var pos = available_positions.pop_front()
		matrix[pos[0]][pos[1]] = elements.pop_front()


func discover_reagents(amount: int):
	pass


func discover_all():
	known_matrix = matrix
