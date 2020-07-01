class_name ReagentDB

const DB = {
	"common": {
		"name": "Comum",
		"image": preload("res://assets/images/reagents/regular.png"),
		"tooltip" : "If not used correctly, deals %s regular damage to a random enemy.",
		"effect" : {"type": "damage", "value": 3, "upgraded_value": 4, "upgraded_boost": {"type": "all", "value": 1}},
		"gold_value" : 5
	},
	"uncommon": {
		"name": "Reagente Incomum",
		"image": preload("res://assets/images/reagents/special.png"),
		"tooltip" : "If not used correctly, deals %s regular damage to a random enemy.",
		"effect" : {"type": "damage", "value": 5, "upgraded_value": 6, "upgraded_boost": {"type": "all", "value": 2}},
		"gold_value" : 25
	},
	"rare": {
		"name": "Reagente Raro",
		"image": preload("res://assets/images/reagents/funky.png"),
		"tooltip" : "If not used correctly, deals %s regular damage to a random enemy.",
		"effect" : {"type": "damage", "value": 8, "upgraded_value": 10, "upgraded_boost": {"type": "all", "value": 3}},
		"gold_value" : 50
	},
	"damaging": {
		"name": "Phoenix's Feather",
		"image": preload("res://assets/images/reagents/feather.png"),
		"tooltip" : "If not used correctly, deals %s regular damage to all enemies.",
		"effect" : {"type": "damage_all", "value": 3, "upgraded_value": 5, "upgraded_boost": {"type": "damage", "value": 2}},
		"gold_value" : 15
	},
	"defensive": {
		"name": "Reagente Defesa",
		"image": preload("res://assets/images/reagents/tasty.png"),
		"tooltip" : "If not used correctly, gives %s shield to user.",
		"effect" : {"type": "shield", "value": 3, "upgraded_value": 5, "upgraded_boost": {"type": "shield", "value": 2}},
		"gold_value" : 15
	},
	"super_damaging": {
		"name": "Reagente Super Dano",
		"image": preload("res://assets/images/reagents/marvellous.png"),
		"tooltip" : "If not used correctly, deals %s regular damage to all enemies.",
		"effect" : {"type": "damage_all", "value": 5, "upgraded_value": 7, "upgraded_boost": {"type": "damage", "value": 3}},
		"gold_value" : 35
	},
	"super_defensive": {
		"name": "Reagente Super Defesa",
		"image": preload("res://assets/images/reagents/juicy.png"),
		"tooltip" : "If not used correctly, gives %s shield to user.",
		"effect" : {"type": "shield", "value": 5, "upgraded_value": 7, "upgraded_boost": {"type": "shield", "value": 3}},
		"gold_value" : 35
	},
	"healing": {
		"name": "Reagente Cura",
		"image": preload("res://assets/images/reagents/suspicious.png"),
		"tooltip" : "If not used correctly, heals the user %s hp.",
		"effect" : {"type": "heal", "value": 1, "upgraded_value": 3, "upgraded_boost": {"type": "heal", "value": 5}},
		"gold_value" : 40
	},
	"poison": {
		"name": "Reagente Poison",
		"image": preload("res://assets/images/reagents/harmless.png"),
		"tooltip" : "If not used correctly, applies %s poison to a random enemy.",
		"effect" : {"type": "status", "status_type": "poison", "positive": false, "value": 2, "upgraded_value": 4, "upgraded_boost": {"type": "status", "value": 2}},
		"gold_value" : 20
	},
	"buff": {
		"name": "Reagente Buff",
		"image": preload("res://assets/images/reagents/funky.png"),
		"tooltip" : "If not used correctly, applies %s temporary strength to user.",
		"effect" : {"type": "status", "status_type": "temp_strength", "positive": true, "value": 2, "upgraded_value": 4, "upgraded_boost": {"type": "status", "value": 2}},
		"gold_value" : 25
	},
	"trash": {
		"name": "Reagente Lixo",
		"image": preload("res://assets/images/reagents/trash.png"),
		"tooltip" : "If not used correctly, deals %s regular damage to the user.",
		"effect" : {"type": "damage_self", "value": 2, "upgraded_value": 1, "upgraded_boost": {"type": "all", "value": 1}},
		"gold_value" : 0
	}
}


static func get_types() -> Array:
	return DB.keys()


static func get_from_name(name: String) -> Dictionary:
	if not DB.has(name):
		push_error("Given type of reagent doesn't exist: " + str(name))
		assert(false)
	return DB[name]
