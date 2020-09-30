class_name ArtifactDB

const COMMON = [
   {
		"id": "poison_kit",
		"name": "Poison Kit",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When acquired, add 3 poison-reagents to your bag",
	},
   {
		"id": "buff_poison",
		"name": "Buff Poison",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Whenever you apply poison, apply 1 extra poison",
	},
	{
		"id": "strength",
		"name": "Strength",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 1 permanent strength",
	},
	{
		"id": "temp_strength",
		"name": "First Hit",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Start each battle with 5 temporary strength",
	},
	{
		"id": "max_hp",
		"name": "Max HP",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "Increase your H.P. by 15",
	},
	{
		"id": "full_rest",
		"name": "Resting Place 1",
		"image": preload("res://assets/images/reagents/comum.png"),
		"description": "When resting, you heal completely",
	},
]

const UNCOMMON = [
	{
		"id": "buff_kit",
		"name": "Buff Kit",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 3 buff-reagents to your bag",
	},
	{
		"id": "debuff_kit",
		"name": "Debuff Kit",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 3 debuff-reagents to your bag",
	},
	{
		"id": "trash_heal",
		"name": "Trash Heal",
		"image": preload("res://assets/images/reagents/incomum.png"),
		"description": "When acquired, add 4 trash-reagents to your bag. Misused trash reagents will heal you instead of harm you",
	},
]

const RARE = [
	{
		"id": "buff_heal",
		"name": "Buff Heal",
		"image": preload("res://assets/images/reagents/raro.png"),
		"description": "Whenever you heal yourself during battle, heal 50% more",
	},
	{
		"id": "midas",
		"name": "Midas",
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
