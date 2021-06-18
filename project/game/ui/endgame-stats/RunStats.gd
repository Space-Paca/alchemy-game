extends Control

const FLOOR_STATS = preload("res://game/ui/endgame-stats/FloorStats.tscn")

const XP_MULT = {"artifacts": 10}

var total_xp : int


func set_player(p: Player):
	for i in p.cur_level:
		var floor_stats = FLOOR_STATS.instance()
		var cleared = i < p.cur_level - 1
		floor_stats.set_amounts(i, cleared, p.floor_stats[i])
		total_xp += floor_stats.total_xp
		$Panel/VBoxContainer/ScrollContainer/VBoxContainer.add_child(floor_stats)
		$Panel/VBoxContainer/ScrollContainer/VBoxContainer.move_child(floor_stats, i)
	
	var xp : int
	
	#recipes
	
	#masterized
	
	#artifacts
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Amount.text =\
			str(p.artifacts.size())
	xp = XP_MULT.artifacts * p.artifacts.size()
	total_xp += xp
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Exp.text =\
			str(xp)
	
	$Panel/VBoxContainer/TotalXP.text = str("Total: ", total_xp)
