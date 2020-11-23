extends Node

var recipes = {}


func _ready():
	var dir := Directory.new()
	var path := "res://database/recipes/"
	if dir.open(path) == OK:
# warning-ignore:return_value_discarded
		dir.list_dir_begin()
		var file_name := dir.get_next() as String
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var recipe := load(str(path, file_name)) as Recipe
				
				# DEBUG
				if recipe.reagents.size() < 2:
					push_error("RecipeManager: %s has less than 2 reagents" % str(path, file_name))
					assert(false)
				if recipe.effects.size() != recipe.effect_args.size():
					push_error("RecipeManager: %s effect and arguments size mismatch" % str(path, file_name))
					assert(false)
				
				recipes[recipe.name] = recipe
			file_name = dir.get_next()
	else:
		print("RecipeManager: An error occurred when trying to access the path.")


func update_recipes_reagent_combinations():
	for recipe in recipes.values():
		recipe.reagent_combinations = []
		var reagent_arrays_to_check = [recipe.reagents.duplicate()]
		var reagent_arrays_viewed = [recipe.reagents.duplicate()]
		while not reagent_arrays_to_check.empty():
			var cur_reagents_array = reagent_arrays_to_check.pop_front()
			recipe.reagent_combinations.append(cur_reagents_array)
			for upgraded_array in ReagentManager.upgraded_arrays(cur_reagents_array):
				var unique = true
				for array_viewed in reagent_arrays_viewed:
					if ReagentManager.is_same_reagent_array(array_viewed, upgraded_array):
						unique = false
						break
				if unique:
					reagent_arrays_to_check.append(upgraded_array)
					reagent_arrays_viewed.append(upgraded_array)
		var err = ResourceSaver.save(recipe.resource_path, recipe)
		assert(not err, "Something went wrong trying to save recipe resource: " + str(recipe.name) + " Error:" + str(err))
