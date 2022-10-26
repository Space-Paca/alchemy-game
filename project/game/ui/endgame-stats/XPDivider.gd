extends Control

signal setup_animation_complete
signal applied_xp
signal content_unlocked(unlock_data)
# warning-ignore:unused_signal
signal unlock_popup_closed

const PROGRESSIONS = ["recipes", "artifacts", "misc"]
const PROGRESSIONS_NAME = ["WISDOM", "TREASURES", "THE_WORLD"]
const AMOUNT_DIGIT = preload("res://game/ui/endgame-stats/AmountDigit.tscn")

onready var xp_pool_amount = $HBoxContainer/AmountContainer
onready var empiric_label = $HBoxContainer/EmpiricLabel
onready var progress_cont = $ProgressThingies
onready var apply_button = $ApplyButton
onready var increasing_xp_sfx_len = preload("res://assets/audio/sfx/increasing_xp_counter.wav").get_length()

var initial_xp_pool = 0
var xp_pool = 0
var animation_active = false
var skip = false

func _ready():
	for child in xp_pool_amount.get_children():
		child.queue_free()
	for child in progress_cont.get_children():
		child.modulate.a = 0
	apply_button.modulate.a = 0
	empiric_label.modulate.a = 0


func _input(event):
	if event.is_action_pressed("left_mouse_button") and animation_active:
		skip_animations()


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
	animation_active = true
	if not skip:
		yield(get_tree().create_timer(.2),"timeout")
		
	initial_xp_pool = value
	xp_pool = value
	for child in xp_pool_amount.get_children():
		child.modulate.a = 0
	update_apply_button()
	
	empiric_label.enter_animation(skip)
	if not skip:
		yield(empiric_label, "animation_finished")

	set_xp_pool_label(value)
	yield(get_tree(),"idle_frame")
	
	var count = xp_pool_amount.get_child_count()
	for child in xp_pool_amount.get_children():
		child.fade_in_dur = 1.0/float(count)
		child.enter_animation(skip)
		AudioManager.play_sfx("increasing_empiric_points", 1.0 + (count-1)*.025)
		if not skip:
			yield(child, "animation_finished")
	if not skip:
		yield(get_tree().create_timer(.2),"timeout")
	setup_xp_progress_bars()


func setup_xp_progress_bars():
	var idx = 0
	for child in progress_cont.get_children():
		child.connect("changed_xp", self, "_on_changed_xp")
		var prog_type = PROGRESSIONS[idx]
		var prog_name = PROGRESSIONS_NAME[idx]
		var cur_level = get_level(prog_type)
		var init_xp = get_level_xp(prog_type)
		var lvl_prog = UnlockManager.get_progression(prog_type)
		var max_xp
		child.slider.editable = false
		if cur_level == 0:
			max_xp = lvl_prog[cur_level]
			child.setup(prog_name, cur_level, init_xp, max_xp, xp_pool)
		elif not Profile.is_max_level(prog_type):
			max_xp = lvl_prog[cur_level] - lvl_prog[cur_level-1]
			child.setup(prog_name, cur_level, init_xp, max_xp, xp_pool)
		else:
			child.start_max_level()
			child.max_level(prog_name)
		idx += 1
		child.enter_animation(skip)
		if not skip:
			yield(child, "animation_finished")
		if not Profile.is_max_level(prog_type):
			child.slider.editable = true
		if not skip:
			yield(get_tree().create_timer(.4),"timeout")
	
	apply_button.enter_animation(skip)
	if not skip:
		yield(apply_button, "animation_finished")
		
	animation_active = false
	#Safety measure for yield in higher function
	yield(get_tree().create_timer(.01),"timeout")
	emit_signal("setup_animation_complete")


func skip_animations():
	animation_active = false
	skip = true
	var elements := []
	elements.append(empiric_label)
	elements.append_array(xp_pool_amount.get_children())
	elements.append_array(progress_cont.get_children())
	elements.append(apply_button)
	
	for element in elements:
		if element.has_method("animate") and element.animation_active:
			element.skip_animation()
			break


func set_xp_pool_label(value):
	for child in xp_pool_amount.get_children():
		child.queue_free()
	value = str(value)
	while value.length() > 0:
		var digit = AMOUNT_DIGIT.instance()
		digit.text = value[0]
		xp_pool_amount.add_child(digit)
		value = value.substr(1)
	yield(get_tree(),"idle_frame")
	update_particle_control()


func set_xp_pool(value):
	xp_pool = value
	set_xp_pool_label(value)
	for child in progress_cont.get_children():
		child.set_available_xp(value)
	update_apply_button()


func update_particle_control():
	#Centralize particle emmiter to middle of digits
	if xp_pool_amount.get_child_count()%2 == 0:
		var digit = xp_pool_amount.get_child(xp_pool_amount.get_child_count()/2)
		$ParticleControl.rect_global_position = digit.rect_global_position + Vector2(0, digit.rect_size.y/2)
	else:
		var digit = xp_pool_amount.get_child(floor(xp_pool_amount.get_child_count()/2.0))
		$ParticleControl.rect_global_position = digit.rect_global_position + digit.rect_size/2


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
	apply_button.disabled = true
	for child in progress_cont.get_children():
		var xp = child.get_modified_xp()
		if xp > 0:
			initial_xp_pool -= xp
			child.apply()

			yield(child, "finished_applying")

			var prog_type = PROGRESSIONS[idx]
			var prog_name = PROGRESSIONS_NAME[idx]
			var cur_level = get_level(prog_type)
			Profile.increase_progression(prog_type, xp)
			if get_level(prog_type) > cur_level:
				if Profile.is_max_level(prog_type):
					child.max_level(prog_name)
				else:
					var new_level = get_level(prog_type)
					var lvl_prog = UnlockManager.get_progression(prog_type)
					var max_xp = lvl_prog[new_level] - lvl_prog[new_level-1]
					child.setup(prog_name, new_level, 0, max_xp, xp_pool)
				unlock_content(idx)
				yield(self, "unlock_popup_closed")
				
		idx += 1
	update_apply_button()
	emit_signal("applied_xp")
