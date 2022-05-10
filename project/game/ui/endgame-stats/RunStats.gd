extends Control

signal animation_finished

const FLOOR_STATS = preload("res://game/ui/endgame-stats/FloorStats.tscn")
const XP_MULT = {"artifacts": 15, "discovered": 5, "mastered": 15}
const THEME = preload("res://assets/themes/general_theme/general_theme.tres")

var total_xp : int
var skip := false
var animation_active := false


func _ready():
	$Panel/VBoxContainer/TotalContainer/EP.change_text_value()
	yield(get_tree(), "idle_frame")
	$Panel/VBoxContainer/TotalContainer/EP.change_text_value(0)


func _input(event):
	if event.is_action_pressed("left_mouse_button") and animation_active:
		skip_animations()


func set_player(p: Player):
	for i in min(p.cur_level, Debug.MAX_FLOOR):
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
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Recipes/Exp.amount =\
			amount * XP_MULT.discovered
	
	#recipes mastered
	amount = p.stats.recipes_mastered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.mastered
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Mastered/Exp.amount =\
			amount * XP_MULT.mastered
	
	#artifacts
	amount = p.artifacts.size()
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Amount.text =\
			str(amount)
	total_xp += amount * XP_MULT.artifacts
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Artifacts/Exp.amount =\
			amount * XP_MULT.artifacts
	
	#tempo da run (nao da pontos)
	set_time_label($Panel/VBoxContainer/ScrollContainer/VBoxContainer/Time/Amount,
			p.stats.time)
	
	#reagentes transfigurados (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Transfigured/Amount.text =\
			str(p.stats.reagents_transfigured)
	
	#reagentes upados (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Upgraded/Amount.text =\
			str(p.stats.reagents_upgraded)
	
	#reagentes removidos (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Removed/Amount.text =\
			str(p.stats.reagents_removed)
	
	#dano dado (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgDealt/Amount.text =\
			str(p.stats.damage_dealt)
	
	#dano recebido (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgTaken/Amount.text =\
			str(p.stats.damage_received)
	
	#dano curado (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgHealed/Amount.text =\
			str(p.stats.damage_healed)
	
	#dano bloqueado (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/DmgBlocked/Amount.text =\
			str(p.stats.damage_blocked)
	
	#escudo ganho (nao da ponto)
	$Panel/VBoxContainer/ScrollContainer/VBoxContainer/Block/Amount.text =\
			str(p.stats.shield_gain)
	
	$Panel/VBoxContainer/TotalContainer/EP.amount = total_xp
	$Panel/VBoxContainer/TotalContainer/EP.change_text_value(total_xp)


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
	animation_active = true
	for element in $Panel/VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if not element.has_method("animate"):
			continue
		element.animate(skip)
		element.set_focus_mode(FOCUS_ALL)
		element.grab_focus()
		element.set_focus_mode(FOCUS_NONE)
		if not skip:
			yield(element, "animation_finished")
	
	$Panel/VBoxContainer/ScrollContainer.theme = THEME
	$Panel/VBoxContainer/TotalContainer.animate(skip)
	if not skip:
		yield($Panel/VBoxContainer/TotalContainer, "animation_finished")
	
	$ScrollBlocker.queue_free()
	
	emit_signal("animation_finished")
	animation_active = false


func skip_animations():
	animation_active = false
	skip = true
	var elements := []
	elements.append_array($Panel/VBoxContainer/ScrollContainer/VBoxContainer.get_children())
	elements.append($Panel/VBoxContainer/TotalContainer)
	
	for element in elements:
		if element.has_method("animate") and element.animation_active:
			element.skip()
			break
