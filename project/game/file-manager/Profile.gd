extends Node

var tutorials = {
	"first_battle": false,
	"recipe_book": false,
	"map": false,
}



func get_save_data():
	var data = {
		"tutorial": tutorials
	}
	
	return data
