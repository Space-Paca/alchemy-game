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


func get_from(combination: Combination):
	return recipes[combination.recipe_name]
