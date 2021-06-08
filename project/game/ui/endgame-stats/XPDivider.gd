extends Control

const PROGRESSIONS = ["recipes", "artifacts", "misc"]

onready var xp_pool_amount_label = $EmpiricLabel/Amount
onready var progress_cont = $ProgressThingies
onready var apply_button = $ApplyButton

var initial_xp_pool = 0
var xp_pool = 0

func _ready():
	for child in progress_cont.get_children():
		child.modulate.a = 0
	apply_button.modulate.a = 0
	$EmpiricLabel.modulate.a = 0
	set_initial_xp_pool(15)


func get_level_xp(prog):
	var level = get_level(prog)
	if level > 0:
		return prog.level_progression[level - 1] - prog.cur_xp
	else:
		return prog.cur_xp


func get_level(prog):
	for i in range(0, prog.level_progression.size()):
		if prog.level_progression[i] > prog.cur_xp:
			return i
	return prog.level_progression.size()


func is_max_level(prog):
	return get_level(prog) == prog.level_progression.size()


func setup_xp_progress_bars():
	var idx = 0
	for child in progress_cont.get_children():
		child.connect("changed_xp", self, "_on_changed_xp")
		var prog_data = Profile.get_progression(PROGRESSIONS[idx])
		var cur_level = get_level(prog_data)
		var init_xp = get_level_xp(prog_data)
		var lvl_prog = prog_data.level_progression
		var max_xp
		if cur_level == 0:
			max_xp = lvl_prog[cur_level]
			child.setup("Unlock " + prog_data.name + "- Level " + str(cur_level), init_xp, max_xp, xp_pool)
		elif not is_max_level(prog_data):
			max_xp = lvl_prog[cur_level] - lvl_prog[cur_level-1]
			child.setup("Unlock " + prog_data.name + "- Level " + str(cur_level), init_xp, max_xp, xp_pool)
		else:
			child.start_max_level()
			child.max_level("Unlock " + prog_data.name + "- MAX LEVEL!")
		idx += 1
		$Tween.interpolate_property(child, "modulate:a", 0, 1, .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		yield(get_tree().create_timer(.4),"timeout")
	$Tween.interpolate_property(apply_button, "modulate:a", 0, 1, .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func set_initial_xp_pool(value):
	yield(get_tree().create_timer(.2),"timeout")
	initial_xp_pool = value
	xp_pool = value
	set_xp_pool_label(0)
	update_apply_button()
	var d = .7
	$Tween.interpolate_property($EmpiricLabel, "modulate:a", 0, 1, d, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_method(self, "set_xp_pool_label", 0, value, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT, d)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	yield(get_tree().create_timer(.2),"timeout")
	setup_xp_progress_bars()


func set_xp_pool_label(value):
	xp_pool_amount_label.text = str(floor(value))


func set_xp_pool(value):
	xp_pool = value
	xp_pool_amount_label.text = str(xp_pool)
	for child in progress_cont.get_children():
		child.set_available_xp(value)
	update_apply_button()


func get_available_xp():
	return xp_pool


func update_apply_button():
	apply_button.disabled = (xp_pool == initial_xp_pool)


func _on_changed_xp(value):
	set_xp_pool(xp_pool - value)


func _on_ApplyButton_pressed():
	var idx = 0
	for child in progress_cont.get_children():
		var xp = child.get_modified_xp()
		if xp > 0:
			initial_xp_pool -= xp
			child.apply()
			var prog_data = Profile.get_progression(PROGRESSIONS[idx])
			yield(child, "finished_applying")
			var cur_level = get_level(prog_data)
			Profile.increase_progression(PROGRESSIONS[idx], xp)
			if get_level(prog_data) > cur_level:
				if is_max_level(prog_data):
					child.max_level("Unlock " + prog_data.name + "- MAX LEVEL!")
				else:
					var new_level = get_level(prog_data)
					var name = "Unlock " + prog_data.name + "- Level " + str(new_level)
					var lvl_prog = prog_data.level_progression
					var max_xp = lvl_prog[new_level] - lvl_prog[new_level-1]
					child.setup(name, 0, max_xp, xp_pool)
		idx += 1
	update_apply_button()
