extends Control

const FLOOR_STATS = preload("res://game/ui/endgame-stats/FloorStats.tscn")

var total_xp : int


func _ready():
	pass


func set_player(p: Player):
	for i in p.cur_level:
		var floor_stats = FLOOR_STATS.instance()
		floor_stats.set_amounts(i, p.floor_stats[i])
		total_xp += floor_stats.total_xp
		$Panel/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(floor_stats)
	
	$Panel/MarginContainer/VBoxContainer/TotalXP.text = str("Total: ", total_xp)
