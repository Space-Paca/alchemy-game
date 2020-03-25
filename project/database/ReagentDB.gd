
var db = {
	"regular": {
		"image": "res://assets/images/reagents/regular.png",
	},
	"special": {
		"image": "res://assets/images/reagents/special.png",
	},
	"harmless": {
		"image": "res://assets/images/reagents/harmless.png",
	},
	"funky": {
		"image": "res://assets/images/reagents/funky.png"
	},
	"tasty": {
		"image": "res://assets/images/reagents/tasty.png"
	},
	"marvellous": {
		"image": "res://assets/images/reagents/marvellous.png"
	},
	"powerful": {
		"image": "res://assets/images/reagents/powerful.png"
	}
}

func get_types():
	return db.keys()

func get(name):
	if not db.has(name):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	return db[name]
