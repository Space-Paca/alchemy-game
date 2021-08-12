extends VBoxContainer

signal animation_finished

const XP_MULT = [
	{"normal": 10, "elite": 20, "monsters": 4, "map": 1},
	{"normal": 15, "elite": 30, "monsters": 6, "map": 1.25},
	{"normal": 20, "elite": 40, "monsters": 8, "map": 1.5},
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
	$NormalEncounters/Exp.amount = xp_value
	
	amount = stats.elite_encounters_finished
	xp_value = XP_MULT[level]["elite"] * amount
	total_xp += xp_value
	$EliteEncounters/Amount.text = str(amount)
	$EliteEncounters/Exp.amount = xp_value
	
	amount = stats.monsters_defeated
	xp_value = XP_MULT[level]["monsters"] * amount
	total_xp += xp_value
	$MonstersDefeated/Amount.text = str(amount)
	$MonstersDefeated/Exp.amount = xp_value
	
	amount = int(floor(stats.percentage_done * 100))
	xp_value = XP_MULT[level]["map"] * amount
	total_xp += xp_value
	$ExplorationRate/Amount.text = str(amount, "%")
	$ExplorationRate/Exp.amount = xp_value
	
	if cleared:
		$RegionClear.show()
		xp_value = REGION_XP[level]
		total_xp += xp_value
		$RegionClear/Exp.amount = xp_value


func animate():
	for child in get_children():
		if child.visible and child.has_method("animate"):
			child.animate()
			yield(child, "animation_finished")
	emit_signal("animation_finished")
