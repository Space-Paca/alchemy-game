class_name ArtifactDB

const COMMON = [
   {
		"id": "poison_kit",
		"name": "Slimy Satchel",
		"image": preload("res://assets/images/artifacts/poison_kit.png"),
		"description": "When acquired, add 3 Noxious Essence reagents to your bag",
		"must_unlock": false,
	},
   {
		"id": "buff_poison",
		"name": "Poisoner's Thesis",
		"image": preload("res://assets/images/artifacts/buff_poison.png"),
		"description": "Whenever you apply poison, apply 1 extra poison",
		"must_unlock": true,
	},
	{
		"id": "strength",
		"name": "Powerstone",
		"image": preload("res://assets/images/artifacts/strength.png"),
		"description": "Start each battle with 3 permanent strength",
		"must_unlock": false,
	},
	{
		"id": "max_hp",
		"name": "Chalice of Life",
		"image": preload("res://assets/images/artifacts/max_hp.png"),
		"description": "When acquired, your total life is increased by 20",
		"must_unlock": false,
	},
	{
		"id": "temp_strength",
		"name": "Morhk Nosering",
		"image": preload("res://assets/images/artifacts/temp_strength.png"),
		"description": "Start each battle with 6 temporary strength",
		"must_unlock": true,
	},
	{
		"id": "great_rest",
		"name": "Warm Blanket",
		"image": preload("res://assets/images/artifacts/great_rest.png"),
		"description": "When resting, you heal 70% of you max health",
		"must_unlock": false,
	},
	{
		"id": "money_bag",
		"name": "Coin Pouch",
		"image": preload("res://assets/images/artifacts/money_bag.png"),
		"description": "When acquired, gain 40 gold",
		"must_unlock": false,
	},
	{
		"id": "blue_oyster",
		"name": "Blue Oyster",
		"image": preload("res://assets/images/artifacts/blue_oyster.png"),
		"description": "Whenever you defeat an elite or boss encounter, gain 1 extra pearl",
		"must_unlock": false,
	},
	{
		"id": "mender_belt",
		"name": "Mender's Belt",
		"image": preload("res://assets/images/artifacts/mender_belt.png"),
		"description": "Whenever you finish a battle, heal 8",
		"must_unlock": false,
	},
	{
		"id": "carapa_buckler",
		"name": "Carapa Buckler",
		"image": preload("res://assets/images/artifacts/carapa_buckler.png"),
		"description": "Start each battle with 10 shield",
		"must_unlock": false,
	},
	{
		"id": "vulture_mask",
		"name": "Vulture Mask",
		"image": preload("res://assets/images/artifacts/vulture_mask.png"),
		"description": "Start each battle against an elite with 5 permanent strength",
		"must_unlock": true,
	},
]

const UNCOMMON = [
	{
		"id": "full_rest",
		"name": "Soothing Teapot",
		"image": preload("res://assets/images/artifacts/full_rest.png"),
		"description": "When resting, you heal completely",
		"must_unlock": true,
	},
	{
		"id": "buff_kit",
		"name": "Powerful Satchel",
		"image": preload("res://assets/images/artifacts/buff_kit.png"),
		"description": "When acquired, add 3 Horn Fragment reagents to your bag",
		"must_unlock": false,
	},
	{
		"id": "debuff_kit",
		"name": "Wicked Satchel",
		"image": preload("res://assets/images/artifacts/debuff_kit.png"),
		"description": "When acquired, add 3 Cracked Skull reagents to your bag",
		"must_unlock": false,
	},
	{
		"id": "trash_heal",
		"name": "Mortar and Pestle",
		"image": preload("res://assets/images/artifacts/trash_heal.png"),
		"description": "When acquired, add 4 Putrid Beetle reagents to your bag. Misused Beetle reagents will heal you instead of harm you",
		"must_unlock": false,
	},
	{
		"id": "strength_plus",
		"name": "Mightstone",
		"image": preload("res://assets/images/artifacts/strength_plus.png"),
		"description": "Start each battle with 8 permanent strength",
		"must_unlock": true,
	},
	{
		"id": "temp_strength_plus",
		"name": "Morhk Chain",
		"image": preload("res://assets/images/artifacts/temp_strength_plus.png"),
		"description": "Start each battle with 12 temporary strength",
		"must_unlock": false,
	},
	{
		"id": "random_kit",
		"name": "Unpredictable Satchel",
		"image": preload("res://assets/images/artifacts/random_kit.png"),
		"description": "When acquired, add 4 random reagents to your bag",
		"must_unlock": false,
	},
	{
		"id": "poisoned_dagger",
		"name": "Poisoned Dagger",
		"image": preload("res://assets/images/artifacts/poisoned_dagger.png"),
		"description": "Whenever you deal unblocked damage to an enemy, apply 1 poison to it",
		"must_unlock": true,
	},
]

const RARE = [
	{
		"id": "buff_heal",
		"name": "Ivory Cup",
		"image": preload("res://assets/images/artifacts/buff_heal.png"),
		"description": "Whenever you heal yourself during battle, heal 50% more",
		"must_unlock": false,
	},
	{
		"id": "midas",
		"name": "Midas' Finger",
		"image": preload("res://assets/images/artifacts/midas.png"),
		"description": "When acquired, triple your current gold",
		"must_unlock": true,
	},
	{
		"id": "heal_leftover",
		"name": "Sprig of Misteltoe",
		"image": preload("res://assets/images/artifacts/heal_leftover.png"),
		"description": "Whenever you end your turn, heal 2 for every reagent left in your hand",
		"must_unlock": false,
	},
	{
		"id": "damage_optimize",
		"name": "Seal of Swords",
		"image": preload("res://assets/images/artifacts/damage_optimize.png"),
		"description": "Whenever you end your turn, if you used all your reagents in recipes, deal 30 damage to all enemies",
		"must_unlock": false,
	},
	{
		"id": "heal_optimize",
		"name": "Seal of Respite",
		"image": preload("res://assets/images/artifacts/heal_optimize.png"),
		"description": "Whenever you end your turn, if you used all your reagents in recipes, you heal 30",
		"must_unlock": false,
	},
	{
		"id": "strength_optimize",
		"name": "Seal of Might",
		"image": preload("res://assets/images/artifacts/strength_optimize.png"),
		"description": "Whenever you end your turn, if you used all your reagents in recipes, you gain 10 permanent strength",
		"must_unlock": false,
	},
	{
		"id": "reveal_map",
		"name": "Silver Sextant",
		"image": preload("res://assets/images/artifacts/reveal_map.png"),
		"description": "All maps are revealed",
		"must_unlock": true,
	},
]

const EVENT = [
	{
		"id": "cursed_pearls",
		"name": "Cursed Pearls",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "When transmuting reagents for gold, you get half the original value",
	},
	{
		"id": "cursed_halberd",
		"name": "Cursed Halberd",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "At the start of each battle, gain 5 permanent strength. At the start of each battle, take 8 damage",
	},
	{
		"id": "cursed_shield",
		"name": "Cursed Shield",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "At the start of each turn, gain 5 shield. At the start of each battle, take 8 damage",
	},
	{
		"id": "bloodcursed_grimoire",
		"name": "Bloodcursed Grimoire",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "Whenever you defeat an enemy, gain 9 life",
	},
	{
		"id": "gold_ankh",
		"name": "Gold Ankh",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "Whenever you finish a battle, gain 10 max health",
	},
	{
		"id": "cursed_scholar_mask",
		"name": "Cursed Scholar's Mask",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "You can't heal in resting circles. Whenever you discover a new recipe, you heal 15% of your max life (doesn't apply on bought recipes)",
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


static func get_artifacts(rarity : String, get_only_unlocked := true) -> Array:
	var artifacts = []
	#var unlocked_artifacts = UnlockManager.get_all_unlocked_artifacts(Profile.)
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


static func has(name: String) -> bool:
	for dict in [EVENT, COMMON, UNCOMMON, RARE]:
		for artifact in dict:
			if artifact.id == name:
				return true
	return false


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
	for artifact in EVENT:
		if artifact.id == name:
			return artifact
	
	assert(false, "Given type of artifact doesn't exist: " + str(name))
	return {}


static func get_tooltip(id: String) -> Dictionary:
	var artifact = get_from_name(id)
	var tooltip = {}
	tooltip.title = artifact.name
	tooltip.title_image = artifact.image
	tooltip.text = artifact.description
	tooltip.subtitle = get_rarity_from_name(artifact.id) + " Artifact"
	
	return tooltip


static func get_rarity_from_name(id: String) -> String:
	for artifact in COMMON:
			if artifact.id == id:
				return "Common"
	for artifact in UNCOMMON:
		if artifact.id == id:
			return "Uncommon"
	for artifact in RARE:
		if artifact.id == id:
			return "Rare"
	for artifact in EVENT:
		if artifact.id == id:
			return "Event"
	
	assert(false, "Given type of artifact doesn't exist: " + str(id))
	return ""
