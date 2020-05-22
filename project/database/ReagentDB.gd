class_name ReagentDB

const DB = {
	"common": {
		"name": "Comum",
		"image": preload("res://assets/images/reagents/regular.png"),
		"tooltip" : "If not used correctly, deals 3 damage to a random enemy",
		"effect" : {"type": "damage", "value": 3},
		"gold_value" : 10
	},
	"uncommon": {
		"name": "Reagente Incomum",
		"image": preload("res://assets/images/reagents/special.png"),
		"tooltip" : "If not used correctly, deals 5 damage to a random enemy",
		"effect" : {"type": "damage", "value": 5},
		"gold_value" : 10
	},
	"rare": {
		"name": "Reagente",
		"image": preload("res://assets/images/reagents/funky.png"),
		"tooltip" : "If not used correctly, deals 5 damage to a random enemy",
		"effect" : {"type": "damage", "value": 5},
		"gold_value" : 10
	},
	"damaging": {
		"name": "Phoenix's Feather",
		"image": preload("res://assets/images/reagents/feather.png"),
		"tooltip" : "If not used correctly, deals 3 damage to all enemies",
		"effect" : {"type": "damage_all", "value": 3},
		"gold_value" : 10
	},
	"defensive": {
		"name": "Reagente Defesa",
		"image": preload("res://assets/images/reagents/tasty.png"),
		"tooltip" : "If not used correctly, gives 3 shield to user",
		"effect" : {"type": "shield", "value": 3},
		"gold_value" : 10
	},
	"super_damaging": {
		"name": "Reagente Super Dano",
		"image": preload("res://assets/images/reagents/marvellous.png"),
		"tooltip" : "If not used correctly, deals 5 damage to all enemies",
		"effect" : {"type": "damage_all", "value": 5},
		"gold_value" : 10
	},
	"super_defensive": {
		"name": "Reagente Super Defesa",
		"image": preload("res://assets/images/reagents/juicy.png"),
		"tooltip" : "If not used correctly, gives 5 shield to user",
		"effect" : {"type": "shield", "value": 5},
		"gold_value" : 10
	},
	"healing": {
		"name": "Reagente Cura",
		"image": preload("res://assets/images/reagents/suspicious.png"),
		"tooltip" : "If not used correctly, heals the user 3 hp",
		"effect" : {"type": "heal", "value": 3},
		"gold_value" : 10
	},
	"catalyst": {
		"name": "Reagente Catalisador",
		"image": preload("res://assets/images/reagents/powerful.png"),
		"tooltip" : "If not used correctly, deals 2 damage to a random enemy",
		"effect" : {"type": "damage", "value": 2},
		"gold_value" : 10
	},
	"poison": {
		"name": "Reagente Poison",
		"image": preload("res://assets/images/reagents/harmless.png"),
		"tooltip" : "If not used correctly, gives 2 poison to a random enemy",
		"effect" : {"type": "status", "status_type": "poison", "amount": 2, "positive": false},
		"gold_value" : 10
	}
}


static func get_types() -> Array:
	return DB.keys()


static func get_from_name(name: String) -> Dictionary:
	if not DB.has(name):
		push_error("Given type of reagent doesn't exist: " + str(name))
		assert(false)
	return DB[name]
