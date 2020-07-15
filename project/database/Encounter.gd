extends Resource
class_name Encounter

export(bool) var is_boss = false
export(bool) var is_elite = false
export(int, 1, 3) var level = 1
export(Array, String, "humunculus", "baby_humunculus", "dodge", "big_buffer", \
 					  "poison",  "baby_poison", "spawner_humunculus", \
					  "delayed_hitter", "baby_slasher", "elite_dodger", "baby_retaliate", \
					  "delayed_hitter_plus", "boss_1", "big_divider", "medium_divider", \
					  "small_divider") var enemies

# Loot table
export(Dictionary) var loot_table := {"common": 0, "uncommon": 0, "rare": 0,
	"damaging": 0, "defensive": 0, "super_damaging": 0, "super_defensive": 0,
	"healing": 0, "buff": 0, "poison": 0}
export(Array, float) var extra_loot_chance : Array


func get_loot() -> Array:
	var loot := []
	var chance = 1
	var extra_chance := extra_loot_chance.duplicate()
	var pool := []
	
	for reagent in loot_table:
		for _i in range(loot_table[reagent]):
			pool.append(reagent)
	
	while chance and chance >= randf():
		pool.shuffle()
		loot.append(pool.front())
		chance = extra_chance.pop_front()
	
	if is_boss or is_elite:
		loot.append("gem")
	
	return loot
