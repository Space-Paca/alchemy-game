class_name ReagentDB

const DB = {
	"common": {
		"image": "res://assets/images/reagents/regular.png",
	},
	"uncommon": {
		"image": "res://assets/images/reagents/special.png",
	},
	"rare": {
		"image": "res://assets/images/reagents/harmless.png",
	},
	"damaging": {
		"image": "res://assets/images/reagents/funky.png"
	},
	"defensive": {
		"image": "res://assets/images/reagents/tasty.png"
	},
	"super_damaging": {
		"image": "res://assets/images/reagents/marvellous.png"
	},
	"super_defensive": {
		"image": "res://assets/images/reagents/juicy.png"
	},
	"healing": {
		"image": "res://assets/images/reagents/suspicious.png"
	},
	"catalyst": {
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
