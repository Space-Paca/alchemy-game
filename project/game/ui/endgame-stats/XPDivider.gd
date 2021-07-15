extends Control

signal setup_animation_complete
signal applied_xp
signal content_unlocked(unlock_data)

const PROGRESSIONS = ["recipes", "artifacts", "misc"]

onready var xp_pool_amount_label = $EmpiricLabel/Amount
onready var progress_cont = $ProgressThingies
onready var apply_button = $ApplyButton
onready var increasing_xp_sfx_len = preload("res://assets/audio/sfx/increasing_xp_counter.wav").get_length()

var initial_xp_pool = 0
var xp_pool = 0

func _ready():
	for child in progress_cont.get_children():
		child.modulate.a = 0
	apply_button.modulate.a = 0
	$EmpiricLabel.modulate.a = 0


func get_level_xp(prog_type):
	var level = get_level(prog_type)
	var prog = UnlockManager.get_progression(prog_type)
	var cur_xp = Profile.get_progression_xp(prog_type)
	if level > 0:
		return cur_xp - prog[level - 1]
	else:
		return cur_xp


func can_apply_xp():
	var all_maxed = true
	var idx = 0
	for child in progress_cont.get_children():
		if not Profile.is_max_level(PROGRESSIONS[idx]):
			all_maxed = false
			break
		idx += 1
	return not all_maxed and xp_pool > 0


func get_level(prog_type):
	return Profile.get_progression_level(prog_type)


func set_initial_xp_pool(value):
	yield(get_tree().create_timer(.2),"timeout")
	initial_xp_pool = value
	xp_pool = value
	set_xp_pool_label(0)
	update_apply_button()
	var delay = .7
	$Tween.interpolate_property($EmpiricLabel, "modulate:a", 0, 1, delay, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	var dur = 1.0
	$Tween.interpolate_method(self, "set_xp_pool_label", 0, value, dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	if value != 0:
		AudioManager.play_sfx("increasing_xp_counter", increasing_xp_sfx_len/dur)
	yield($Tween, "tween_completed")
	yield(get_tree().create_timer(.2),"timeout")
	setup_xp_progress_bars()


func setup_xp_progress_bars():
	var idx = 0
	for child in progress_cont.get_children():
		child.connect("changed_xp", self, "_on_changed_xp")
		var prog_type = PROGRESSIONS[idx]
		var prog_data = Profile.get_progression(prog_type)
		var cur_level = get_level(prog_type)
		var init_xp = get_level_xp(prog_type)
		var lvl_prog = UnlockManager.get_progression(prog_type)
		var max_xp
		if cur_level == 0:
			max_xp = lvl_prog[cur_level]
			child.setup(prog_data.name, cur_level, init_xp, max_xp, xp_pool)
		elif not Profile.is_max_level(prog_type):
			max_xp = lvl_prog[cur_level] - lvl_prog[cur_level-1]
			child.setup(prog_data.name, cur_level, init_xp, max_xp, xp_pool)
		else:
			child.start_max_level()
			child.max_level(prog_data.name)
		idx += 1
		$Tween.interpolate_property(child, "modulate:a", 0, 1, .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		yield(get_tree().create_timer(.4),"timeout")
	$Tween.interpolate_property(apply_button, "modulate:a", 0, 1, .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	emit_signal("setup_animation_complete")


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


func unlock_content(index: int):
	var unlock_data = UnlockManager.get_unlock_data(PROGRESSIONS[index])
	emit_signal("content_unlocked", unlock_data)


func _on_changed_xp(value):
	set_xp_pool(xp_pool - value)


func _on_ApplyButton_pressed():
	var idx = 0
	for child in progress_cont.get_children():
		var xp = child.get_modified_xp()
		if xp > 0:
			initial_xp_pool -= xp
			child.apply()
			yield(child, "finished_applying")
			var prog_type = PROGRESSIONS[idx]
			var cur_level = get_level(prog_type)
			var prog_data = Profile.get_progression(PROGRESSIONS[idx])
			Profile.increase_progression(prog_type, xp)
			if get_level(prog_type) > cur_level:
				if Profile.is_max_level(prog_type):
					child.max_level(prog_data.name)
				else:
					var new_level = get_level(prog_type)
					var lvl_prog = UnlockManager.get_progression(prog_type)
					var max_xp = lvl_prog[new_level] - lvl_prog[new_level-1]
					child.setup(prog_data.name, new_level, 0, max_xp, xp_pool)
				unlock_content(idx)
		idx += 1
	update_apply_button()
	emit_signal("applied_xp")
