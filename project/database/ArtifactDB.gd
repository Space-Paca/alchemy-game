class_name ArtifactDB

const COMMON = [
	{
		"id": "blue_oyster",
		"name": "ART_BLUE_OYSTER_NAME",
		"image": preload("res://assets/images/artifacts/blue_oyster.png"),
		"description": "ART_BLUE_OYSTER_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "buff_poison",
		"name": "ART_BUFF_POISON_NAME",
		"image": preload("res://assets/images/artifacts/buff_poison.png"),
		"description": "ART_BUFF_POISON_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "buff_shield",
		"name": "ART_BUFF_SHIELD_NAME",
		"image": preload("res://assets/images/artifacts/buff_poison.png"),
		"description": "ART_BUFF_SHIELD_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "carapa_buckler",
		"name": "ART_CARAPA_BUCKLER_NAME",
		"image": preload("res://assets/images/artifacts/carapa_buckler.png"),
		"description": "ART_CARAPA_BUCKLER_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "great_rest",
		"name": "ART_GREAT_REST_NAME",
		"image": preload("res://assets/images/artifacts/great_rest.png"),
		"description": "ART_GREAT_REST_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "keep_shield_partial",
		"name": "ART_KEEP_SHIELD_PARTIAL_NAME",
		"image": preload("res://assets/images/artifacts/hand_veknor.png"),
		"description": "ART_KEEP_SHIELD_PARTIAL_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "max_hp",
		"name": "ART_MAX_HP_NAME",
		"image": preload("res://assets/images/artifacts/max_hp.png"),
		"description": "ART_MAX_HP_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "mender_belt",
		"name": "ART_MENDER_BELT_NAME",
		"image": preload("res://assets/images/artifacts/mender_belt.png"),
		"description": "ART_MENDER_BELT_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "money_bag",
		"name": "ART_MONEY_BAG_NAME",
		"image": preload("res://assets/images/artifacts/money_bag.png"),
		"description": "ART_MONEY_BAG_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "poison_kit",
		"name": "ART_POISON_KIT_NAME",
		"image": preload("res://assets/images/artifacts/poison_kit.png"),
		"description": "ART_POISON_KIT_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "strength",
		"name": "ART_STRENGTH_NAME",
		"image": preload("res://assets/images/artifacts/strength.png"),
		"description": "ART_STRENGTH_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "temp_strength",
		"name": "ART_TEMP_STRENGTH_NAME",
		"image": preload("res://assets/images/artifacts/temp_strength.png"),
		"description": "ART_TEMP_STRENGTH_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "vulture_mask",
		"name": "ART_VULTURE_MASK_NAME",
		"image": preload("res://assets/images/artifacts/vulture_mask.png"),
		"description": "ART_VULTURE_MASK_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
]

const UNCOMMON = [
	{
		"id": "buff_kit",
		"name": "ART_BUFF_KIT_NAME",
		"image": preload("res://assets/images/artifacts/buff_kit.png"),
		"description": "ART_BUFF_KIT_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "buff_shield_plus",
		"name": "ART_BUFF_SHIELD_PLUS_NAME",
		"image": preload("res://assets/images/artifacts/buff_poison.png"),
		"description": "ART_BUFF_SHIELD_PLUS_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "debuff_kit",
		"name": "ART_DEBUFF_KIT_NAME",
		"image": preload("res://assets/images/artifacts/debuff_kit.png"),
		"description": "ART_DEBUFF_KIT_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "full_rest",
		"name": "ART_FULL_REST_NAME",
		"image": preload("res://assets/images/artifacts/full_rest.png"),
		"description": "ART_FULL_REST_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "hand_veknor",
		"name": "ART_HAND_VEKNOR_NAME",
		"image": preload("res://assets/images/artifacts/hand_veknor.png"),
		"description": "ART_HAND_VEKNOR_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "keep_shield_total",
		"name": "ART_KEEP_SHIELD_TOTAL_NAME",
		"image": preload("res://assets/images/artifacts/hand_veknor.png"),
		"description": "ART_KEEP_SHIELD_TOTAL_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "trash_heal",
		"name": "ART_TRASH_HEAL_NAME",
		"image": preload("res://assets/images/artifacts/trash_heal.png"),
		"description": "ART_TRASH_HEAL_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "strength_plus",
		"name": "ART_STRENGTH_PLUS_NAME",
		"image": preload("res://assets/images/artifacts/strength_plus.png"),
		"description": "ART_STRENGTH_PLUS_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "temp_strength_plus",
		"name": "ART_TEMP_STRENGTH_PLUS_NAME",
		"image": preload("res://assets/images/artifacts/temp_strength_plus.png"),
		"description": "ART_TEMP_STRENGTH_PLUS_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "random_kit",
		"name": "ART_RANDOM_KIT_NAME",
		"image": preload("res://assets/images/artifacts/random_kit.png"),
		"description": "ART_RANDOM_KIT_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "poisoned_dagger",
		"name": "ART_POISONED_DAGGER_NAME",
		"image": preload("res://assets/images/artifacts/poisoned_dagger.png"),
		"description": "ART_POISONED_DAGGER_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "avoid_death",
		"name": "ART_AVOID_DEATH_NAME",
		"image": preload("res://assets/images/artifacts/avoid_death.png"),
		"description": "ART_AVOID_DEATH_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
]

const RARE = [
	{
		"id": "buff_heal",
		"name": "ART_BUFF_HEAL_NAME",
		"image": preload("res://assets/images/artifacts/buff_heal.png"),
		"description": "ART_BUFF_HEAL_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "damage_optimize",
		"name": "ART_DAMAGE_OPTIMIZE_NAME",
		"image": preload("res://assets/images/artifacts/damage_optimize.png"),
		"description": "ART_DAMAGE_OPTIMIZE_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "heal_leftover",
		"name": "ART_HEAL_LEFTOVER_NAME",
		"image": preload("res://assets/images/artifacts/heal_leftover.png"),
		"description": "ART_HEAL_LEFTOVER_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "heal_optimize",
		"name": "ART_HEAL_OPTIMIZE_NAME",
		"image": preload("res://assets/images/artifacts/heal_optimize.png"),
		"description": "ART_HEAL_OPTIMIZE_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "midas",
		"name": "ART_MIDAS_NAME",
		"image": preload("res://assets/images/artifacts/midas.png"),
		"description": "ART_MIDAS_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "reveal_map",
		"name": "ART_REVEAL_MAP_NAME",
		"image": preload("res://assets/images/artifacts/reveal_map.png"),
		"description": "ART_REVEAL_MAP_DESC",
		"must_unlock": true,
		"use_on_demo": true,
	},
	{
		"id": "shield_damage",
		"name": "ART_SHIELD_DAMAGE_NAME",
		"image": preload("res://assets/images/artifacts/reveal_map.png"),
		"description": "ART_SHIELD_DAMAGE_DESC",
		"must_unlock": false,
		"use_on_demo": false,
	},
	{
		"id": "strength_optimize",
		"name": "ART_STRENGTH_OPTIMIZE_NAME",
		"image": preload("res://assets/images/artifacts/strength_optimize.png"),
		"description": "ART_STRENGTH_OPTIMIZE_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
]

const EVENT = [
	{
		"id": "cursed_pearls",
		"name": "ART_CURSED_PEARLS_NAME",
		"image": preload("res://assets/images/artifacts/cursed_pearls.png"),
		"description": "ART_CURSED_PEARLS_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "cursed_halberd",
		"name": "ART_CURSED_HALBERD_NAME",
		"image": preload("res://assets/images/artifacts/cursed_halberd.png"),
		"description": "ART_CURSED_HALBERD_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "cursed_shield",
		"name": "ART_CURSED_SHIELD_NAME",
		"image": preload("res://assets/images/artifacts/cursed_shield.png"),
		"description": "ART_CURSED_SHIELD_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "bloodcursed_grimoire",
		"name": "ART_BLOODCURSED_GRIMOIRE_NAME",
		"image": preload("res://assets/images/artifacts/bloodcursed_grimoire.png"),
		"description": "ART_BLOODCURSED_GRIMOIRE_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "gold_ankh",
		"name": "ART_GOLD_ANKH_NAME",
		"image": preload("res://assets/images/artifacts/gold_ankh.png"),
		"description": "ART_GOLD_ANKH_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
	{
		"id": "cursed_scholar_mask",
		"name": "ART_CURSED_MASK_NAME",
		"image": preload("res://assets/images/artifacts/cursed_scholar_mask.png"),
		"description": "ART_CURSED_MASK_DESC",
		"must_unlock": false,
		"use_on_demo": true,
	},
]

static func get_artifacts_data(rarity : String, get_only_unlocked := true) -> Array:
	var unlocked_artifacts = UnlockManager.get_all_unlocked_artifacts()
	var pool
	if rarity == "common":
		pool = COMMON.duplicate()
	elif rarity == "uncommon":
		pool = UNCOMMON.duplicate()
	elif rarity == "rare":
		pool = RARE.duplicate()
	elif rarity == "event":
		pool = EVENT.duplicate()
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		pool = []
	
	if get_only_unlocked:
		var to_remove = []
		for artifact in pool:
			if artifact.must_unlock and not unlocked_artifacts.has(artifact.id) and\
				(not Debug.is_demo or artifact.use_on_demo):
				to_remove.append(artifact)
		for rem_art in to_remove:
			pool.remove(pool.find(rem_art))

	return pool

static func get_artifacts(rarity : String, get_only_unlocked := true) -> Array:
	var artifacts = []
	var unlocked_artifacts = UnlockManager.get_all_unlocked_artifacts()
	var pool
	if rarity == "common":
		pool = COMMON
	elif rarity == "uncommon":
		pool = UNCOMMON
	elif rarity == "rare":
		pool = RARE
	elif rarity == "event":
		pool = EVENT
	else:
		assert(false, "Not a valid rarity for artifacts: " + str(rarity))
		return []

	for artifact in pool:
		if (not get_only_unlocked or not artifact.must_unlock or unlocked_artifacts.has(artifact.id))and\
		   (not Debug.is_demo or artifact.use_on_demo):
				artifacts.append(artifact.id)
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
	tooltip.subtitle = get_rarity_from_name(artifact.id)
	
	return tooltip


static func get_rarity_from_name(id: String) -> String:
	for artifact in COMMON:
			if artifact.id == id:
				return "COMMON_ARTIFACT"
	for artifact in UNCOMMON:
		if artifact.id == id:
			return "UNCOMMON_ARTIFACT"
	for artifact in RARE:
		if artifact.id == id:
			return "RARE_ARTIFACT"
	for artifact in EVENT:
		if artifact.id == id:
			return "EVENT_ARTIFACT"
	
	assert(false, "Given type of artifact doesn't exist: " + str(id))
	return ""
