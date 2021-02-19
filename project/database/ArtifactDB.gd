class_name ArtifactDB

const COMMON = [
   {
		"id": "poison_kit",
		"name": "Slimy Satchel",
		"image": preload("res://assets/images/artifacts/poison_kit.png"),
		"description": "When acquired, add 3 poison reagents to your bag",
	},
   {
		"id": "buff_poison",
		"name": "Poisoner's Thesis",
		"image": preload("res://assets/images/artifacts/buff_poison.png"),
		"description": "Whenever you apply poison, apply 1 extra poison",
	},
	{
		"id": "strength",
		"name": "Powerstone",
		"image": preload("res://assets/images/artifacts/strength.png"),
		"description": "Start each battle with 3 permanent strength",
	},
	{
		"id": "max_hp",
		"name": "Chalice of Life",
		"image": preload("res://assets/images/artifacts/max_hp.png"),
		"description": "Increase your H.P. by 20",
	},
	{
		"id": "temp_strength",
		"name": "Morhk Nosering",
		"image": preload("res://assets/images/artifacts/temp_strength.png"),
		"description": "Start each battle with 6 temporary strength",
	},
	{
		"id": "great_rest",
		"name": "Warm Blanket",
		"image": preload("res://assets/images/artifacts/great_rest.png"),
		"description": "When resting, you heal 70% of you max health",
	},
	{
		"id": "money_bag",
		"name": "Coin Pouch",
		"image": preload("res://assets/images/artifacts/money_bag.png"),
		"description": "When acquired, gain 40 gold",
	},
	{
		"id": "blue_oyster",
		"name": "Blue Oyster",
		"image": preload("res://assets/images/artifacts/blue_oyster.png"),
		"description": "Whenever you defeat an elite or boss encounter, gain 1 extra pearl",
	},
	{
		"id": "mender_belt",
		"name": "Mender's Belt",
		"image": preload("res://assets/images/artifacts/mender_belt.png"),
		"description": "Whenever you finish a battle, heal 8",
	},
	{
		"id": "carapa_buckler",
		"name": "Carapa Buckler",
		"image": preload("res://assets/images/artifacts/carapa_buckler.png"),
		"description": "Start each battle with 10 shield",
	},
	{
		"id": "vulture_mask",
		"name": "Vulture Mask",
		"image": preload("res://assets/images/artifacts/vulture_mask.png"),
		"description": "Start each battle against an elite with 5 permanent strength",
	},
]

const UNCOMMON = [
	{
		"id": "full_rest",
		"name": "Soothing Teapot",
		"image": preload("res://assets/images/artifacts/full_rest.png"),
		"description": "When resting, you heal completely",
	},
	{
		"id": "buff_kit",
		"name": "Powerful Satchel",
		"image": preload("res://assets/images/artifacts/buff_kit.png"),
		"description": "When acquired, add 3 buff-reagents to your bag",
	},
	{
		"id": "debuff_kit",
		"name": "Wicked Satchel",
		"image": preload("res://assets/images/artifacts/debuff_kit.png"),
		"description": "When acquired, add 3 debuff-reagents to your bag",
	},
	{
		"id": "trash_heal",
		"name": "Mortar and Pestle",
		"image": preload("res://assets/images/artifacts/trash_heal.png"),
		"description": "When acquired, add 4 trash-reagents to your bag. Misused trash reagents will heal you instead of harm you",
	},
	{
		"id": "strength_plus",
		"name": "Mightstone",
		"image": preload("res://assets/images/artifacts/strength_plus.png"),
		"description": "Start each battle with 8 permanent strength",
	},
	{
		"id": "temp_strength_plus",
		"name": "Morhk Chain",
		"image": preload("res://assets/images/artifacts/temp_strength_plus.png"),
		"description": "Start each battle with 12 temporary strength",
	},
	{
		"id": "random_kit",
		"name": "Unpredictable Satchel",
		"image": preload("res://assets/images/artifacts/random_kit.png"),
		"description": "When acquired, add 4 random reagents to your bag",
	},
	{
		"id": "poisoned_dagger",
		"name": "Poisoned Dagger",
		"image": preload("res://assets/images/artifacts/poisoned_dagger.png"),
		"description": "Whenever you deal unblocked damage to an enemy, apply 1 poison to it",
	},	{
		"id": "buff_kit",
		"name": "Powerful Satchel",
		"image": preload("res://assets/images/artifacts/buff_kit.png"),
		"description": "When acquired, add 3 buff-reagents to your bag",
	},
	{
		"id": "debuff_kit",
		"name": "Wicked Satchel",
		"image": preload("res://assets/images/artifacts/debuff_kit.png"),
		"description": "When acquired, add 3 debuff-reagents to your bag",
	},
	{
		"id": "trash_heal",
		"name": "Mortar and Pestle",
		"image": preload("res://assets/images/artifacts/trash_heal.png"),
		"description": "When acquired, add 4 trash-reagents to your bag. Misused trash reagents will heal you instead of harm you",
	},
	{
		"id": "strength_plus",
		"name": "Mightstone",
		"image": preload("res://assets/images/artifacts/strength_plus.png"),
		"description": "Start each battle with 8 permanent strength",
	},
	{
		"id": "temp_strength_plus",
		"name": "Morhk Chain",
		"image": preload("res://assets/images/artifacts/temp_strength_plus.png"),
		"description": "Start each battle with 20 temporary strength",
	},
	{
		"id": "random_kit",
		"name": "Unpredictable Satchel",
		"image": preload("res://assets/images/artifacts/random_kit.png"),
		"description": "When acquired, add 4 random reagents to your bag",
	},
	{
		"id": "poisoned_dagger",
		"name": "Poisoned Dagger",
		"image": preload("res://assets/images/artifacts/poisoned_dagger.png"),
		"description": "Whenever you deal unblocked damage to an enemy, apply 1 poison to it",
	},
]

const RARE = [
	{
		"id": "buff_heal",
		"name": "Ivory Cup",
		"image": preload("res://assets/images/artifacts/buff_heal.png"),
		"description": "Whenever you heal yourself during battle, heal 50% more",
	},
	{
		"id": "midas",
		"name": "Midas' Finger",
		"image": preload("res://assets/images/artifacts/midas.png"),
		"description": "When acquired, triple your current gold",
	},
	{
		"id": "heal_leftover",
		"name": "Sprig of Misteltoe",
		"image": preload("res://assets/images/artifacts/heal_leftover.png"),
		"description": "Whenever you end your turn, heal 2 for every reagent left in your hand",
	},
	{
		"id": "damage_optimize",
		"name": "Seal of Swords",
		"image": preload("res://assets/images/artifacts/damage_optimize.png"),
		"description": "Whenever you end your turn, if you used all your reagents in recipes, deal 30 damage to all enemies",
	},
	{
		"id": "heal_optimize",
		"name": "Seal of Respite",
		"image": preload("res://assets/images/artifacts/heal_optimize.png"),
		"description": "Whenever you end your turn, if you used all your reagents in recipes, you heal 30",
	},
	{
		"id": "strength_optimize",
		"name": "Seal of Might",
		"image": preload("res://assets/images/artifacts/strength_optimize.png"),
		"description": "Whenever you end your turn, if you used all your reagents in recipes, you gain 10 permanent strength",
	},
	{
		"id": "reveal_map",
		"name": "Silver Sextant",
		"image": preload("res://assets/images/artifacts/reveal_map.png"),
		"description": "All maps are revealed",
	},
]

const EVENT = [
	{
		"id": "cursed_pearls",
		"name": "Cursed Pearls",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "When transmuting reagents for gold, you get half the original value",
	},
]

static func get_artifacts_data(rarity : String) -> Array:
	if rarity == "common":
		return COMMON.duplicate()
	elif rarity == "uncommon":
		return UNCOMMON.duplicate()
	elif rarity == "rare":
		return RARE.duplicate()
	elif rarity == "event":
		return EVENT.duplicate()
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
	elif rarity == "event":
		for artifact in EVENT:
			artifacts.append(artifact.id)
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		return []
	return artifacts

static func get_from_name(name: String) -> Dictionary:
	for artifact in EVENT:
		if artifact.id == name:
			return artifact
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


static func get_tooltip(name: String) -> Dictionary:
	var artifact = get_from_name(name)
	var tooltip = {}
	tooltip.title = artifact.name
	tooltip.title_image = artifact.image
	tooltip.text = artifact.description
	tooltip.subtitle = get_rarity_from_name(artifact.id) + " Artifact"
	
	return tooltip


static func get_rarity_from_name(name: String) -> String:
	for artifact in EVENT:
		if artifact.id == name:
			return "Event"
	for artifact in COMMON:
			if artifact.id == name:
				return "Common"
	for artifact in UNCOMMON:
		if artifact.id == name:
			return "Uncommon"
	for artifact in RARE:
		if artifact.id == name:
			return "Rare"
	
	assert(false, "Given type of artifact doesn't exist: " + str(name))
	return ""

