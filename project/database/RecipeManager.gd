extends Node

var recipes = {}


func _ready():
	var dir := Directory.new()
	var path := "res://database/recipes/"
	if dir.open(path) == OK:
# warning-ignore:return_value_discarded
		dir.list_dir_begin()
		var file_name := (dir.get_next() as String)
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var recipe := (load(str(path, file_name)) as Recipe)
				if recipe.reagents.size() < 2:
					print("RecipeManager: %a has less than 2 reagents" % file_name)
				recipes[file_name.rstrip(".tres")] = recipe
			file_name = dir.get_next()
	else:
		print("RecipeManager: An error occurred when trying to access the path.")
