extends VBoxContainer

const XP_MULT = [
	{"normal": 1, "elite": 1, "monsters": 1, "map": 1},
	{"normal": 1, "elite": 1, "monsters": 1, "map": 1},
	{"normal": 1, "elite": 1, "monsters": 1, "map": 1},
]
const REGION_XP = [100, 200, 300]

var total_xp : int


func set_amounts(level: int, cleared: bool, stats: Dictionary):
	var amount : int
	var xp_value : int
	
	$FloorName.text = Map.FLOOR_LABEL[level]
	
	amount = stats.normal_encounters_finished
	xp_value = XP_MULT[level]["normal"] * amount
	total_xp += xp_value
	$NormalEncounters/Amount.text = str(amount)
	$NormalEncounters/Exp.text = str(xp_value)
	
	amount = stats.elite_encounters_finished
	xp_value = XP_MULT[level]["elite"] * amount
	total_xp += xp_value
	$EliteEncounters/Amount.text = str(amount)
	$EliteEncounters/Exp.text = str(xp_value)
	
	amount = stats.monsters_defeated
	xp_value = XP_MULT[level]["monsters"] * amount
	total_xp += xp_value
	$MonstersDefeated/Amount.text = str(amount)
	$MonstersDefeated/Exp.text = str(xp_value)
	
	amount = int(floor(stats.percentage_done * 100))
	xp_value = XP_MULT[level]["map"] * amount
	total_xp += xp_value
	$ExplorationRate/Amount.text = str(amount, "%")
	$ExplorationRate/Exp.text = str(xp_value)
	
	if cleared:
		$RegionClear.show()
		xp_value = REGION_XP[level]
		total_xp += xp_value
		$RegionClear/Exp.text = str(xp_value)
