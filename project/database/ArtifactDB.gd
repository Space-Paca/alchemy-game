class_name ArtifactDB

const COMMON = [
   {
		"id": "poison_kit",
		"name": "Slimy Satchel",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When acquired, add 3 poison-reagents to your bag",
	},
   {
		"id": "buff_poison",
		"name": "Poisoner's Thesis",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Whenever you apply poison, apply 1 extra poison",
	},
	{
		"id": "strength",
		"name": "Powerstone",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 3 permanent strength",
	},
	{
		"id": "max_hp",
		"name": "Chalice of Life",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Increase your H.P. by 20",
	},
	{
		"id": "temp_strength",
		"name": "Morhk Nosering",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 10 temporary strength",
	},
	{
		"id": "great_rest",
		"name": "Warm Blanket",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When resting, you heal 70% of you max health",
	},
	{
		"id": "money_bag",
		"name": "Coin Pouch",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When acquired, gain 40 gold",
	},
	{
		"id": "blue_oyster",
		"name": "Elite Rewards",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Whenever you defeat an elite or boss encounter, gain 1 extra pearl",
	},
	{
		"id": "mender_belt",
		"name": "Mender's Belt",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Whenever you finish a battle, heal 8.",
	},
	{
		"id": "carapa_buckler",
		"name": "Carapa Buckler",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 10 shield.",
	},
	{
		"id": "vulture_mask",
		"name": "Vulture Mask",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle against an elite with 5 permanent strength.",
	},
]

const UNCOMMON = [
	{
		"id": "full_rest",
		"name": "Soothing Teapot",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When resting, you heal completely",
	},
	{
		"id": "buff_kit",
		"name": "Powerful Satchel",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 3 buff-reagents to your bag",
	},
	{
		"id": "debuff_kit",
		"name": "Wicked Satchel",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 3 debuff-reagents to your bag",
	},
	{
		"id": "trash_heal",
		"name": "Mortar and Pestle",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 4 trash-reagents to your bag. Misused trash reagents will heal you instead of harm you",
	},
	{
		"id": "strength_plus",
		"name": "Mightstone",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 8 permanent strength",
	},
	{
		"id": "temp_strength_plus",
		"name": "Morhk Chain",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 20 temporary strength",
	},
	{
		"id": "random_kit",
		"name": "Unpredictable Satchel",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 4 random reagents to your bag",
	},
]

const RARE = [
	{
		"id": "buff_heal",
		"name": "Ivory Cup",
		"image": preload("res://assets/images/reagents/raro.png"),
		"description": "Whenever you heal yourself during battle, heal 50% more",
	},
	{
		"id": "midas",
		"name": "Midas' Finger",
		"image": preload("res://assets/images/reagents/raro.png"),
		"description": "When acquired, triple your current gold",
	},
]

static func get_artifacts_data(rarity : String) -> Array:
	if rarity == "common":
		return COMMON.duplicate()
	elif rarity == "uncommon":
		return UNCOMMON.duplicate()
	elif rarity == "rare":
		return RARE.duplicate()
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		return []

static func get_artifacts(rarity : String) -> Array:
	var artifacts = []
	if rarity == "common":
		for artifact in COMMON:
			artifacts.append(artifact.id)
	elif rarity == "uncommon":
		for artifact in UNCOMMON:
			artifacts.append(artifact.id)
	elif rarity == "rare":
		for artifact in RARE:
			artifacts.append(artifact.id)
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		return []
	return artifacts

static func get_from_name(name: String) -> Dictionary:
	for artifact in COMMON:
			if artifact.id == name:
				return artifact
	for artifact in UNCOMMON:
		if artifact.id == name:
			return artifact
	for artifact in RARE:
		if artifact.id == name:
			return artifact
	
	assert(false, "Given type of artifact doesn't exist: " + str(name))
	return {}
