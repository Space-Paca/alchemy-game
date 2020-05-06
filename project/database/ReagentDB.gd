class_name ReagentDB

const DB = {
	"common": {
		"name": "Reagente Comum",
		"image": preload("res://assets/images/reagents/Reagent 1.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	},
	"uncommon": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/special.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	},
	"rare": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/harmless.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	},
	"damaging": {
		"name": "Reagente Dano",
		"image": preload("res://assets/images/reagents/funky.png"),
		"tooltip" : "When this reagent doesn't react, does smthing",
	},
	"defensive": {
		"name": "Reagente Defesa",
		"image": preload("res://assets/images/reagents/tasty.png"),
		"tooltip" : "When this reagent doesn't react, does sssomething",
	},
	"super_damaging": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/marvellous.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	},
	"super_defensive": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/juicy.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	},
	"healing": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/suspicious.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	},
	"catalyst": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/powerful.png"),
		"tooltip" : "When this reagent doesn't react, does something",
	}
}


static func get_types() -> Array:
	return DB.keys()


static func get_from_name(name: String) -> Dictionary:
	if not DB.has(name):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	return DB[name]
