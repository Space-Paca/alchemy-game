extends Node

const REAGENT = preload("res://game/reagents/Reagent.tscn")
const FONT_PATH = "res://assets/fonts/TooltipImageFont.tres"


func random_type():
	var types = ReagentDB.get_types()
	randomize()
	types.shuffle() 
	return types[0] if types[0] != "unknown" else types[1]


func create_object(type: String):
	var reagent_data = ReagentDB.get_from_name(type)
	var reagent = REAGENT.instance()
	
	#Duplicate material so shader parameters only affect this object
	var mat_override = reagent.get_node("Image").get_material().duplicate()
	reagent.get_node("Image").set_material(mat_override)
	
	reagent.type = type
	reagent.set_image(reagent_data.image)
	return reagent


func get_data(type: String):
	return ReagentDB.get_from_name(type)

#Given a base reagent, returns all reagents that can substitute into it
func substitute_into(base_reagent):
	var upgrade_list = []
	var all_reagents = ReagentDB.get_reagents()
	for reagent_type in all_reagents:
		for substitute_reagent in all_reagents[reagent_type].substitute:
			if substitute_reagent == base_reagent:
				upgrade_list.append(reagent_type)
				break
	return upgrade_list


func randomize_reagent(reagent):
	var type = random_type()
	var reagent_data = ReagentDB.get_from_name(type)
	reagent.type = type
	reagent.set_image(reagent_data.image)


func get_tooltip(type: String, upgraded:= false, unstable:= false, burned:= false):
	var data = get_data(type)
	var text
	var title
	data.tooltip = tr(data.tooltip)
	data.name = tr(data.name)
	if not upgraded:
		title = data.name
		text = data.tooltip % data.effect.value
	else:
		title = data.name + "+"
		text = data.tooltip % data.effect.upgraded_value + ". "
		text += tr("BOOST_RECIPES") % \
				tr(data.effect.upgraded_boost.type)
		text += " " + str(data.effect.upgraded_boost.value) + "."
	if unstable:
		text += " " + tr("UNSTABLE") + "."
	if burned:
		text += " " + tr("ON_FIRE") + "."
	
	var subtitle = tr(data.rarity + "_REAGENT")
	
	var tooltip = {"title": title, "text": text, \
				   "title_image": data.tooltip_image_path, "subtitle": subtitle}

	return tooltip


func get_substitution_tooltip(type):
	var data = get_data(type)
	if data.substitute.size() <= 0:
		return null
	
	var text
	if data.substitute.size() == 1:
		text = tr("SUBSTITUTION_TOOLTIP_SINGULAR")
	else:
		text = tr("SUBSTITUTION_TOOLTIP_PLURAL")
	text += ": "
	for sub_reagent in data.substitute:
		var sub_data = get_data(sub_reagent)
		var path = sub_data.image.get_path()
		text += "[font="+FONT_PATH+"][img=48x48]"+path+"[/img][/font]  "
	var tooltip = {"title": "SUBSTITUTES", "text": text, \
				   "title_image": data.tooltip_image_path}
	
	return tooltip


#Given an array of reagents for a recipe, and and array of given reagentes, 
#checks if you can create the recipe with the given reagents, taking into
#consideration substitutions. If possible, will return an array of indexes
#for which reagents to use in the given_reagents array
func get_reagents_to_use_2(recipe_array: Array, given_reagents : Array):
	var given = []
	var given_rank = []
	#Bitmask where 1 means we still need this reagent from recipe array
	var need_to_use = (1 << recipe_array.size()) - 1
	#Memoization bitmask matrix, where each line if for each given reagent,
	#And inside is an array of each possible bitmap
	var memoization = []
	
	for i in given_reagents.size():
		var reagent = given_reagents[i]
		var data = ReagentDB.get_from_name(reagent)
		var possible_substitutions = data.substitute
		possible_substitutions.append(reagent)
		given.append([])
		given_rank.append(data.rank)
		memoization.append([])
		for _j in need_to_use + 1:
			memoization[i].append(-1)
		for j in recipe_array.size():
			if possible_substitutions.has(recipe_array[j]):
				given[i].append(j)

	var result = pd_recursion(given, given_rank, memoization, 0, need_to_use)
	if result >= INF:
		return false
	else:
		#Fazer o parse dos resultados pra dizer quais reagentes usar
		return result


func pd_recursion(given, given_rank, memoization, idx, mask):
	if idx == given.size():
		if mask == 0: #Used all reagents sucessfully
			return 0
		else: #Didn't use all reagents sucessfully
			return INF

	
	var result = memoization[idx][mask]
	if result == -1: #Didn't check this given reagent
		result = pd_recursion(given, given_rank, memoization, idx+1, mask)
		
		for reagent in given[idx]:
			if (mask >> reagent)%2 == 1:
				result = min(result, given_rank[idx] + pd_recursion(given, given_rank, memoization, idx+1, mask^(1<<reagent)))
	return result


#Given an array of reagents for a recipe, and and array of given reagentes, 
#checks if you can create the recipe with the given reagents, taking into
#consideration substitutions. If possible, will return an array of indexes
#for which reagents to use in the given_reagents array
func get_reagents_to_use(recipe_array: Array, given_reagents : Array):
	var reagent_arrays_to_check = [given_reagents]
	var reagent_arrays_viewed = []
	var correct_reagents
	while not reagent_arrays_to_check.empty():
		var cur_reagents_array = reagent_arrays_to_check.pop_front()
		correct_reagents = try_reagents(recipe_array, cur_reagents_array)
		if correct_reagents:
			return correct_reagents
		else:
			#Previous hand isn't valid, will add all possible 1-substitution available from it
			for i in cur_reagents_array.size():
				var reagent = cur_reagents_array[i]
				if reagent:
					var reagent_data = ReagentManager.get_data(reagent)
					for sub_reagent in reagent_data.substitute:
						var new_array = cur_reagents_array.duplicate(true)
						new_array[i] = sub_reagent
						var unique = true
						for array_viewed in reagent_arrays_viewed:
							if is_same_reagent_array(array_viewed, new_array):
								unique = false
								break
						if unique:
							reagent_arrays_to_check.append(new_array)
							reagent_arrays_viewed.append(new_array)
	return false

func is_same_reagent_array(array1, array2):
	var a1 = array1.duplicate()
	for reagent in array2:
		var i = a1.find_last(reagent) 
		if i == -1:
			return false
		a1.remove(i)
	if a1.empty():
		return true
	return false

#Returns an array containing all possible one-reagent downgrade from a given array
#(downgrade means that the original reagent substitutes into another)
func downgraded_arrays(reagent_array):
	var downgraded_array_list = []
	for i in reagent_array.size():
		var reagent = reagent_array[i]
		var data = get_data(reagent)
		for substitute in data.substitute:
			var new_array = reagent_array.duplicate()
			new_array[i] = substitute
			downgraded_array_list.append(new_array)
	
	return downgraded_array_list


#Returns an array containing all possible one-reagent upgrade from a given array
#(upgrade means that another reagent can substitute into one of its reagents)
func upgraded_arrays(reagent_array):
	var upgraded_array_list = []
	for i in reagent_array.size():
		var reagent = reagent_array[i]
		for substitute_reagent in substitute_into(reagent):
			var new_array = reagent_array.duplicate()
			new_array[i] = substitute_reagent
			upgraded_array_list.append(new_array)
	
	return upgraded_array_list


func get_array_from_matrix(reagent_matrix):
	var array = []
	for i in reagent_matrix.size():
		for reagent in reagent_matrix[i]:
			if reagent:
				array.append(reagent)
	return array


func create_matrix_from_array(original_matrix, reagent_array):
	var matrix = original_matrix.duplicate(true)
	var count = 0
	for i in matrix.size():
		for j in matrix[i].size():
			if matrix[i][j]:
				matrix[i][j] = reagent_array[count]
				count += 1
	return matrix


#Given a reagent matrix, returns all possible matrixes considering its reagent substitutions
func get_all_substitution_matrices(original_reagent_matrix):
	var final_arrays = []
	var original_reagent_array = get_array_from_matrix(original_reagent_matrix)
	var reagent_arrays_to_check = [original_reagent_array]
	var reagent_arrays_viewed = [original_reagent_array]
	while not reagent_arrays_to_check.empty():
		var cur_reagents_array = reagent_arrays_to_check.pop_front()
		final_arrays.append(cur_reagents_array)
		for substituted_array in ReagentManager.downgraded_arrays(cur_reagents_array):
			var unique = true
			for array_viewed in reagent_arrays_viewed:
				if ReagentManager.is_same_reagent_array(array_viewed, substituted_array):
					unique = false
					break
			if unique:
				reagent_arrays_to_check.append(substituted_array)
				reagent_arrays_viewed.append(substituted_array)
	
	var possible_matrices = []
	for array in final_arrays:
		possible_matrices.append(create_matrix_from_array(original_reagent_matrix, array))
	return possible_matrices


#Checks if the given hand reagents contains all reagents needed for reagent array
func try_reagents(reagent_array, hand_reagents_array):
	var comparing_reagents = reagent_array.duplicate() 
	var correct_reagent_displays := []
	for i in hand_reagents_array.size():
		correct_reagent_displays.append(false)
	var i = 0
	while not comparing_reagents.empty() and i < hand_reagents_array.size():
		var reagent = hand_reagents_array[i]
		for other in comparing_reagents:
			if reagent == other:
				correct_reagent_displays[i] = reagent
				comparing_reagents.erase(other)
				break
		i += 1
	if comparing_reagents.empty():
		return correct_reagent_displays
	else:
		return null
