extends Control

const PROGRESSIONS = ["recipes", "artifacts", "misc"]

onready var xp_pool_amount_label = $Amount
onready var progress_cont = $ProgressThingies
onready var apply_button = $ApplyButton

var initial_xp_pool = 0
var xp_pool = 0

func _ready():
	set_initial_xp_pool(15)
	setup_xp_progress_bars()


func get_level_xp(prog):
	var level = get_level(prog)
	if level > 0:
		return prog.level_progression[level - 1] - prog.cur_xp
	else:
		return prog.cur_xp
		


func get_level(prog):
	for i in range(0, prog.size()):
		if prog.level_progression[i] > prog.cur_xp:
			return i
	return prog.size()

func setup_xp_progress_bars():
	var idx = 0
	for child in progress_cont.get_children():
		child.connect("changed_xp", self, "_on_changed_xp")
		var prog_data = Profile.get_progression(PROGRESSIONS[idx])
		var cur_level = get_level(prog_data)
		var init_xp = get_level_xp(prog_data)
		child.setup("Unlock " + prog_data.name, init_xp, prog_data.level_progression[cur_level], xp_pool)
		idx += 1


func set_initial_xp_pool(value):
	initial_xp_pool = value
	xp_pool = value
	xp_pool_amount_label.text = str(xp_pool)
	update_apply_button()


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
			Profile.increase_progression(PROGRESSIONS[idx], xp)
			child.apply()
			yield(child, "finished_applying")
		idx += 1
	update_apply_button()
