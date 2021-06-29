extends Control

const FLOOR_STATS = preload("res://game/ui/endgame-stats/FloorStats.tscn")
const XP_MULT = {"artifacts": 10, "discovered": 5, "mastered": 10}
const THEME = preload("res://assets/themes/general_theme/general_theme.tres")

var total_xp : int
var elements := []


func set_player(p: Player):
	for i in p.cur_level:
		var floor_stats = FLOOR_STATS.instance()
		var cleared = i < p.cur_level - 1
		floor_stats.set_amounts(i, cleared, p.floor_stats[i])
		total_xp += floor_stats.total_xp
		$Panel/VBoxContainer/ScrollContainer/VBoxContainer.add_child(floor_stats)
		$Panel/VBoxContainer/ScrollContainer/VBoxContainer.move_child(floor_stats, i)
		elements.append(floor_stats)
	
	var amount : int
	
	#recipes discovered
	amount = p.stats.recipes_discovered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Recipes/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.discovered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Recipes/Exp.amount =\
			amount * XP_MULT.discovered
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Recipes)
	
	#recipes mastered
	amount = p.stats.recipes_mastered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.mastered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered/Exp.amount =\
			amount * XP_MULT.mastered
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered)
	
	#artifacts
	amount = p.artifacts.size()
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.artifacts
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Exp.amount =\
			amount * XP_MULT.artifacts
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts)
	
	#tempo da run (nao da pontos)
	set_time_label($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Time/Label,
			p.stats.time)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Time)
	
	#reagentes transfigurados (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Transfigured/Amount.text =\
			str(p.stats.reagents_transfigured)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Transfigured)
	
	#reagentes upados (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Upgraded/Amount.text =\
			str(p.stats.reagents_upgraded)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Upgraded)
	
	#reagentes removidos (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Removed/Amount.text =\
			str(p.stats.reagents_removed)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Removed)
	
	#dano dado (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgDealt/Amount.text =\
			str(p.stats.damage_dealt)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgDealt)
	
	#dano recebido (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgTaken/Amount.text =\
			str(p.stats.damage_received)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgTaken)
	
	#dano curado (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgHealed/Amount.text =\
			str(p.stats.damage_healed)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgHealed)
	
	#dano bloqueado (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgBlocked/Amount.text =\
			str(p.stats.damage_blocked)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgBlocked)
	
	#escudo ganho (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Block/Amount.text =\
			str(p.stats.shield_gain)
	elements.append($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Block)
	
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


func begin_animations():
	print(elements)
	
	for element in $Panel/VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if not element.has_method("animate"):
			continue
		element.animate()
		element.set_focus_mode(FOCUS_ALL)
		element.grab_focus()
		element.set_focus_mode(FOCUS_NONE)
		yield(element, "animation_finished")
	
	$ScrollBlocker.queue_free()
	$Panel/VBoxContainer/ScrollContainer.theme = THEME
