extends Control

const FLOOR_STATS = preload("res://game/ui/endgame-stats/FloorStats.tscn")

const XP_MULT = {"artifacts": 10, "discovered": 5, "mastered": 10}

var total_xp : int


func set_player(p: Player):
	for i in p.cur_level:
		var floor_stats = FLOOR_STATS.instance()
		var cleared = i < p.cur_level - 1
		floor_stats.set_amounts(i, cleared, p.floor_stats[i])
		total_xp += floor_stats.total_xp
		$Panel/VBoxContainer/ScrollContainer/VBoxContainer.add_child(floor_stats)
		$Panel/VBoxContainer/ScrollContainer/VBoxContainer.move_child(floor_stats, i)
	
	var amount : int
	
	#recipes discovered
	amount = p.stats.recipes_discovered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Recipes/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.discovered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Recipes/Exp.text =\
			str(amount * XP_MULT.discovered)
	
	#recipes mastered
	amount = p.stats.recipes_mastered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.mastered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered/Exp.text =\
			str(amount * XP_MULT.mastered)
	
	#artifacts
	amount = p.artifacts.size()
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.artifacts
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Exp.text =\
			str(amount * XP_MULT.artifacts)
	
	#tempo da run (nao da pontos)
	set_time_label($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Time/Label,
			p.stats.time)
	
	#reagentes removidos (nao da ponto)
	#reagentes transmutados (nao da ponto)
	#dano recebido (nao da ponto)
	#dano dado (nao da ponto)
	#dano bloqueado (nao da ponto)
	#dano curado (nao da ponto)
	
	$Panel/VBoxContainer/TotalXP.text = str("Total: ", total_xp)


func set_time_label(label: Label, time: float):
	var h := int(floor(time/3600.0))
	time = fmod(time, 3600)
	var m := int(floor(time/60.0))
	time = fmod(time, 60)
	
	if h:
		label.text = str(h, ":")
	label.text += "%02d:%02d" % [m, int(time)]
	label.text += ("%.2f"%(time-int(time))).substr(1)
