extends VBoxContainer

const FLOOR_NAMES = ["Floor 1", "Floor 2", "Floor 3"]
const XP_MULT = {
	1: {"normal": 1, "elite": 1, "monsters": 1, "map": 1},
	2: {"normal": 1, "elite": 1, "monsters": 1, "map": 1},
	3: {"normal": 1, "elite": 1, "monsters": 1, "map": 1},
}

var total_xp : int


func set_amounts(level: int, normal: int, elite: int, monsters: int,
		map: float):
	var xp_value : int
	
	$FloorName.text = FLOOR_NAMES[level-1]
	
	$NormalEncounters/Amount.text = str(normal)
	xp_value = XP_MULT[level]["normal"] * normal
	total_xp += xp_value
	$NormalEncounters/Exp.text = str(xp_value)
	
	$EliteEncounters/Amount.text = str(elite)
	xp_value = XP_MULT[level]["elite"] * elite
	total_xp += xp_value
	$EliteEncounters/Exp.text = str(xp_value)
	
	$MonstersDefeated/Amount.text = str(monsters)
	xp_value = XP_MULT[level]["monsters"] * monsters
	total_xp += xp_value
	$MonstersDefeated/Exp.text = str(xp_value)
	
	var map_percent = int(floor(map * 100))
	$ExplorationRate/Amount.text = str(map_percent, "%")
	xp_value = XP_MULT[level]["map"] * map_percent
	total_xp += xp_value
	$ExplorationRate/Exp.text = str(xp_value)
