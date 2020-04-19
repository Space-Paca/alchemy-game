extends Resource
class_name Encounter

export(bool) var is_boss = false
export(int, 1, 3) var level = 1
export(Array, String, "skeleton", "wolf", "robot") var enemies

# Loot table
export(Dictionary) var loot_table := {"common": 0, "uncommon": 0, "rare": 0,
	"damaging": 0, "defensive": 0, "super_damaging": 0, "super_defensive": 0,
	"healing": 0, "catalyst": 0}
export(Array, float) var extra_loot_chance : Array


func get_loot() -> Array:
	var loot := []
	var chance := 1
	var extra_chance := extra_loot_chance.duplicate()
	var pool := []
	
	for reagent in loot_table:
		for i in range(loot_table[reagent]):
			pool.append(reagent)
	
	while chance and chance >= randf():
		pool.shuffle()
		loot.append(pool.front())
		chance = extra_chance.pop_front()
	
	return loot
