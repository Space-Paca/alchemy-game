class_name ReagentDB

const DB = {
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


static func get_types() -> Array:
	return DB.keys()


static func get_from_name(name: String) -> Dictionary:
	if not DB.has(name):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	return DB[name]
