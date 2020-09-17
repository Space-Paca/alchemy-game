class_name ArtifactDB

const COMMON = {
	"poison_kit": {
		"name": "Poison Kit",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When acquired, add 3 poison-reagents to your bag",
	},
	"buff_poison": {
		"name": "Buff Poison",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Whenever you apply poison, apply 1 extra poison",
	},
	"strength": {
		"name": "Strength",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 1 permanent strength",
	},
	"max_hp": {
		"name": "Max HP",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Increase your H.P. by 15",
	},
}

const UNCOMMON = {
	"buff_kit": {
		"name": "Buff Kit",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 3 buff-reagents to your bag",
	},
	"debuff_kit": {
		"name": "Debuff Kit",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 3 debuff-reagents to your bag",
	},
	"trash_heal": {
		"name": "Trash Heal",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 4 trash-reagents to your bag. Misused trash reagents will heal you instead of harm you",
	},

}

const RARE = {
	"buff_heal": {
		"name": "Buff Heal",
		"image": preload("res://assets/images/reagents/raro.png"),
		"description": "Whenever you heal yourself during battle, heal 50% more",
	},
	"midas": {
		"name": "Midas",
		"image": preload("res://assets/images/reagents/raro.png"),
		"description": "When acquired, triple your current gold",
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
