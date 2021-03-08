extends Node
class_name Combination

signal fully_discovered

var grid_size : int
var recipe : Recipe
var matrix : Array
var known_matrix : Array
var unknown_reagent_coords : Array
var discovered : bool
var reagent_amounts := {}
var hints := 0


func load_from_data(data, _recipe):
	recipe = _recipe
	grid_size = recipe.grid_size
	matrix = data.matrix
	known_matrix = data.known_matrix
	unknown_reagent_coords = data.unknown_reagent_coords
	discovered = data.discovered
	reagent_amounts = data.reagent_amounts
	hints = data.hints

func create_from_recipe(_recipe: Recipe, combinations: Dictionary):
	recipe = _recipe
	grid_size = recipe.grid_size
	var available_positions := []
	var elements := (recipe.reagents.duplicate() as Array)
	
	# Counting reagents
	elements.sort()
	for reagent in elements:
		if reagent_amounts.has(reagent):
			reagent_amounts[reagent] += 1
		else:
			reagent_amounts[reagent] = 1
	
	# Initializing matrices
	for i in range(grid_size):
		var line = []
		var unknown_line = []
		for j in range(grid_size):
			line.append(null)
			unknown_line.append("unknown")
			unknown_reagent_coords.append([i, j])
			available_positions.append([i, j])
		matrix.append(line)
		known_matrix.append(unknown_line)
	
	while(true):
		var temp_matrix = matrix.duplicate(true)
		var temp_available_pos = available_positions.duplicate(true)
		var temp_elements = elements.duplicate(true)
		
		# Placing the first two reagents that guarantee grid size consistency
		temp_elements.shuffle()
		var pos1 : Array
		var pos2 : Array
		if randf() < .5:
			pos1 = [0, randi() % grid_size]
			pos2 = [grid_size - 1, randi() % grid_size]
		else:
			pos1 = [randi() % grid_size, 0]
			pos2 = [randi() % grid_size, grid_size - 1]
		temp_matrix[pos1[0]][pos1[1]] = temp_elements.pop_front()
		temp_matrix[pos2[0]][pos2[1]] = temp_elements.pop_front()
		temp_available_pos.erase(pos1)
		temp_available_pos.erase(pos2)
		
		# Placing the rest
		temp_available_pos.shuffle()
		while not temp_elements.empty():
			var pos = temp_available_pos.pop_front()
			temp_matrix[pos[0]][pos[1]] = temp_elements.pop_front()
		
		#Check if there isn't another recipe with the same layout,
		#but with reagents that can substitute into the exact recipe
		if check_if_unique(temp_matrix, combinations):
			matrix = temp_matrix
			break


func check_if_unique(test_matrix: Array, combinations: Dictionary):
	if not combinations.has(grid_size):
		return true
	for comb in combinations[grid_size]:
		if is_downgraded_version_of(comb.matrix, test_matrix) or\
		   is_downgraded_version_of(test_matrix, comb.matrix):
			return false
	return true


#Checks if matrix1 can be downgraded into matrix2 via reagents substitutes
func is_downgraded_version_of(matrix1:Array, matrix2:Array):
	for i in range(grid_size):
		for j in range(grid_size):
			#Same reagents, continue comparison
			if matrix1[i][j] == matrix2[i][j]:
				continue
			#Check if reagent isn't nil
			if matrix1[i][j]:
				var equal = false
				var data = ReagentManager.get_data(matrix1[i][j])
				#Check for equality for each substitute the reagent can have
				for reagent in data.substitute:
					if reagent == matrix2[i][j]:
						equal = true
						break
				if equal:
					continue
				else:
					return false
			#Check if matrix1 reagent is nil, cant downgrade into matrix2
			else:
				return false
	return true


func get_hint(which := 0):
	if not which:
		hints += 1
	elif hints > which or discovered:
		return
	else:
		hints = which
	
	match hints:
		1:
			reveal_all_but(3)
		2:
			reveal_all_but(2)
		_:
			discover_all_reagents()


func reveal_all_but(amount: int):
	var kept := []
	var different_reagents = 0
	
	for coords in unknown_reagent_coords:
		var reagent = matrix[coords[0]][coords[1]]
		if reagent and not kept.has(reagent):
			different_reagents += 1
		kept.append(reagent)
	
	while kept.size() > amount:
		if (different_reagents >= amount and kept.has(null)) or kept.count(null) > 1:
			kept.erase(null)
		else:
			var removed = false
			for i in kept.size():
				if kept.count(kept[i]) > 1:
					kept.remove(i)
					removed = true
					break
			if not removed:
				kept.remove(0)
	
	unknown_reagent_coords.shuffle()
	
	for coords in unknown_reagent_coords.duplicate():
		var reagent = matrix[coords[0]][coords[1]]
		if reagent in kept:
			kept.erase(reagent)
		else:
			known_matrix[coords[0]][coords[1]] = reagent
			unknown_reagent_coords.erase(coords)


func discover_all_reagents(emit := true):
	if not discovered:
		discovered = true
		known_matrix = matrix
		unknown_reagent_coords.clear()
		if emit:
			emit_signal("fully_discovered", self)
