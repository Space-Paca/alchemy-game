class_name ArtifactDB

const COMMON = {
	"poison_kit": {
		"name": "Poison Kit",
		"image": preload("res://assets/images/reagents/comum.png"),
	},
	"buff_poison": {
		"name": "Buff Poison",
		"image": preload("res://assets/images/reagents/comum.png"),
	},
	"strength": {
		"name": "Strength",
		"image": preload("res://assets/images/reagents/comum.png"),
	},
	"max_hp": {
		"name": "Max HP",
		"image": preload("res://assets/images/reagents/comum.png"),
	},
}

const UNCOMMON = {
	"buff_kit": {
		"name": "Buff Kit",
		"image": preload("res://assets/images/reagents/incomum.png"),
	},
	"debuff_kit": {
		"name": "Debuff Kit",
		"image": preload("res://assets/images/reagents/incomum.png"),
	},
	"trash_heal": {
		"name": "Trash Heal",
		"image": preload("res://assets/images/reagents/incomum.png"),
	},

}

const RARE = {
	"buff_heal": {
		"name": "Buff Heal",
		"image": preload("res://assets/images/reagents/raro.png"),
	},
	"midas": {
		"name": "Midas",
		"image": preload("res://assets/images/reagents/raro.png"),
	},
}

static func get_artifacts_data(rarity : String) -> Dictionary:
	if rarity == "common":
		return COMMON.duplicate()
	elif rarity == "uncommon":
		return UNCOMMON.duplicate()
	elif rarity == "rare":
		return RARE.duplicate()
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		return {}

static func get_artifacts(rarity : String) -> Array:
	if rarity == "common":
		return COMMON.keys()
	elif rarity == "uncommon":
		return UNCOMMON.keys()
	elif rarity == "rare":
		return RARE.keys()
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		return []

static func get_from_name(name: String) -> Dictionary:
	if COMMON.has(name):
		return COMMON[name]
	elif UNCOMMON.has(name):
		return UNCOMMON[name]
	elif RARE.has(name):
		return RARE[name]
	else:
		push_error("Given type of reagent doesn't exist: " + str(name))
		assert(false)
		return {}
