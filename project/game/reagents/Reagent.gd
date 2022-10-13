extends Control

const SHAKE_DEGREE = 5
const FREEZE_SPEED = 3
const BURN_SPEED = 3
const HIGHLIGHT_SPEED = 5
const HIGHLIGHT_TARGET = 1.6
const ROTATION_FACTOR = 50
const SPEED = .35
const SPEED_TURBO = .7

signal reached_target_pos
signal started_dragging
signal stopped_dragging
signal quick_place
signal hovering
signal stopped_hovering
signal finished_combine_animation
signal unrestrained_slot
signal destroyed
signal exiled
signal exploded

onready var image = $Image
onready var tooltip = $TooltipCollision
onready var burned_node = $Burned

var stop_auto_moving := false
var orbit = false
var orbit_dir := Vector2()
var hovering := false
var is_drag = false
var can_drag = true
var disable_drag = false
var drag_offset = Vector2(0,0)
var slot = null # current slot this reagent is in
var target_position = rect_position
var type = "none"
var image_path : String
var shake := 0.0
var dispenser = null
var returning_to_dispenser := false
var speed_mod := 1.0
var effect_mod := 1.0
var upgraded := false
var unstable := false
var frozen := false
var burned := false
var highlighted := false
var tooltip_enabled = false


func _ready():
	burned_node.self_modulate.a = 0
	burned_node.get_node("AnimationPlayer").playback_speed = rand_range(0.6, 1.4)


func _process(delta):
	#Shake effect
	if shake > 0:
		randomize()
		var shake_offset = Vector2(rand_range(-SHAKE_DEGREE, SHAKE_DEGREE), \
								   rand_range(-SHAKE_DEGREE, SHAKE_DEGREE))
		rect_position += shake_offset * shake
	
	#Freeze effect
	if not is_frozen():
		$Image.modulate.r = min($Image.modulate.r + FREEZE_SPEED*delta, 1)
	else:
		$Image.modulate.r = max($Image.modulate.r - FREEZE_SPEED*delta, 0)
	
	
	#Freeze effect
	if not is_burned():
		burned_node.self_modulate.a = max(burned_node.self_modulate.a - BURN_SPEED*delta, 0)
	else:
		burned_node.self_modulate.a = min(burned_node.self_modulate.a + BURN_SPEED*delta, 1)
	
	
	#Highlight effect
	if highlighted:
		modulate.r = min(modulate.r + HIGHLIGHT_SPEED*delta, HIGHLIGHT_TARGET)
		modulate.g = min(modulate.g + HIGHLIGHT_SPEED*delta, HIGHLIGHT_TARGET)
		modulate.b = min(modulate.b + HIGHLIGHT_SPEED*delta, HIGHLIGHT_TARGET)
	else:
		modulate.r = max(modulate.r - HIGHLIGHT_SPEED*delta, 1)
		modulate.g = max(modulate.g - HIGHLIGHT_SPEED*delta, 1)
		modulate.b = max(modulate.b - HIGHLIGHT_SPEED*delta, 1)
	
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_drag = false
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_drag:
		var target = get_global_mouse_position() + drag_offset
		var diff = (target - rect_position)
		rect_rotation = round(lerp(rect_rotation, sign(diff.x)*diff.length()*.9, ROTATION_FACTOR*delta))
		rect_rotation = min(max(rect_rotation, -65), 65)
		rect_position = target
	elif not is_drag and target_position and not stop_auto_moving:
		if rect_position.distance_to(target_position) > 0:
			var speed = SPEED_TURBO if Profile.get_option("turbo_mode") else SPEED
			rect_position += (target_position - rect_position)*speed*speed_mod
			if (target_position - rect_position).length() < 1:
				if not disable_drag:
					can_drag = true
				rect_position = target_position
				#target_position = null
				emit_signal("reached_target_pos")
	if not is_drag:
		rect_rotation = lerp(rect_rotation, 0, ROTATION_FACTOR*delta)
	if orbit:
		var dir = orbit - rect_position
		if dir.length() > 0:
			dir *= 1/pow(dir.length(), 2)*50
		else:
			dir *= 500*Vector2(1,0)
		var centripetal_force = dir.rotated(PI/2).normalized() * delta * 300
		dir = dir*delta
		orbit_dir += dir
		rect_position += orbit_dir + centripetal_force


func set_image(texture):
	$Image.texture = texture


func get_data():
	var data = {
		"type": type,
		"upgraded": upgraded,
		"unstable": unstable,
		"frozen": frozen,
		"burned": burned,
	}
	return data


func load_data(data):
	frozen = data.frozen
	burned = data.burned
	unstable = data.unstable
	if data.upgraded:
		upgrade()


func error_effect():
	# warning-ignore:return_value_discarded
	$Tween.interpolate_property($Image, "modulate", Color.red, Color.white,
			.5, Tween.TRANS_SINE, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	$Tween.start()


func quick_place():
	if not TutorialLayer.active:
		emit_signal("quick_place", self)


func is_frozen():
	return frozen


func freeze():
	frozen = true


func unfreeze():
	frozen = false


func is_burned():
	return burned


func burn():
	AudioManager.play_sfx("burn_reagent")
	burned = true
	burned_node.get_node("AnimationPlayer").play("idle")


func unburn():
	burned = false
	burned_node.get_node("AnimationPlayer").stop()



func enable_dragging():
	can_drag = true
	disable_drag = false


func clear_tweens():
	$Tween.remove_all()


func start_shaking_and_destroy():
	var dur = .1 if Profile.get_option("turbo_mode") else .9
	$Tween.interpolate_property(self, "shake", 0, 4, dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	if not Profile.get_option("turbo_mode"):
		yield(get_tree().create_timer(.2), "timeout")
	AudioManager.play_sfx("destroy_reagent")


func start_shaking_and_exile():
	var dur = .1 if Profile.get_option("turbo_mode") else .9
	$Tween.interpolate_property(self, "shake", 0, 4, dur, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	if not Profile.get_option("turbo_mode"):
		yield(get_tree().create_timer(.2), "timeout")
	AudioManager.play_sfx("exile_reagent")


func combine_animation(grid_center: Vector2, duration: float, second_animation: bool):
	unhighlight()
	var center = grid_center + -rect_size/2
	#target_position = center
	stop_auto_moving = true
	$CombineTween.interpolate_property(self, "rect_position", rect_position, center, \
								duration, Tween.TRANS_BACK, Tween.EASE_IN)
	$CombineTween.interpolate_method(self, "set_grayscale", 0, 1, duration, Tween.TRANS_QUAD, Tween.EASE_IN) 
	$CombineTween.interpolate_property(self, "shake", 0, 1, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$CombineTween.start()
	$CombineTween.interpolate_method(ShakeCam, "set_continuous_shake", .05, .25,
			duration)
	yield($CombineTween, "tween_all_completed")
	ShakeCam.set_continuous_shake(0, ShakeCam.COMBINATION_ANIM)
	shake = 0.0
	if second_animation:
		orbit = center
		stop_auto_moving = true
	else:
		stop_auto_moving = false
	emit_signal("finished_combine_animation")


func reset_to_gridslot(gridslot):
	gridslot.set_reagent(self)
	$CombineTween.interpolate_method(self, "set_grayscale", 1, 0, .15, Tween.TRANS_QUAD, Tween.EASE_IN) 
	$CombineTween.start()


func set_grayscale(value: float):
	image.material.set_shader_param("grayscale", value)


func stop_hover_effect():
	hovering = false
	slight_shrink()


func destroy():
	orbit = false
	stop_auto_moving = false
	start_shaking_and_destroy()
	var speed = 9 if Profile.get_option("turbo_mode") else 1
	$AnimationPlayer.play("destroy", -1, speed)
	yield($AnimationPlayer, "animation_finished")
	emit_signal("destroyed", self)
	queue_free()


func exile():
	orbit = false
	stop_auto_moving = false
	start_shaking_and_exile()
	var speed = 9 if Profile.get_option("turbo_mode") else 1
	$AnimationPlayer.play("exile", -1, speed)
	yield($AnimationPlayer, "animation_finished")
	emit_signal("exiled", self)
	queue_free()


func hover_effect():
	if not TutorialLayer.active:
		hovering = true
		AudioManager.play_sfx("hover_reagent")
		slight_grow()


func pick_effect():
	AudioManager.play_sfx("pick_reagent")
	slight_grow()


func drop_effect():
	AudioManager.play_sfx("drop_reagent")
	slight_shrink()


func slight_grow():
	var scale = 1.6
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(scale,scale), .05/effect_mod, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func super_grow():
	var scale = 1.8
	$Tween.interpolate_property(self, "rect_scale", Vector2(0,0), Vector2(scale,scale), .15, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()


func grow():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .5/effect_mod, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()


func grow_and_shrink():
	shake = 0.0
	$Tween.interpolate_method(self, "set_grayscale", 1.0, 0.0, .2, Tween.TRANS_LINEAR, Tween.EASE_IN) 
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .05/effect_mod, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0,0), .2/effect_mod, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func slight_shrink():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .05/effect_mod, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func shrink():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0,0), .15/effect_mod, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func highlight():
	highlighted = true
	if slot and slot.type == "hand":
		slot.highlight()
	


func unhighlight():
	highlighted = false
	if slot and slot.type == "hand":
		slot.unhighlight()


func return_to_dispenser():
	assert(dispenser, "Reagent doesn't have a dispenser")
	if returning_to_dispenser:
		return
	
	returning_to_dispenser = true
	
	if slot:
		slot.remove_reagent()
	slot = null
	target_position = dispenser.get_pos()
	
	disable_dragging()
	yield(self, "reached_target_pos")
	dispenser.set_quantity(dispenser.get_quantity() + 1)
	queue_free()


func start_dragging():
	pick_effect()
	is_drag = true
	drag_offset = -get_local_mouse_position()
	remove_tooltips()
	emit_signal("started_dragging", self)


func stop_dragging():
	emit_signal("stopped_dragging", self)


func start_hovering():
	emit_signal("hovering", self)


func stop_hovering():
	emit_signal("stopped_hovering", self)


func disable_tooltips():
	remove_tooltips()
	$TooltipCollision.disable()


func enable_tooltips():
	tooltip.enable()


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func toggle_unstable():
	unstable = not unstable
	if unstable:
		$AnimationPlayer.play("unstable")
		randomize()
		$AnimationPlayer.seek(rand_range(0,1.5))
	else:
		$AnimationPlayer.play("idle")


func explode():
	$AnimationPlayer.play("explode")


func explode_end():
	AudioManager.play_sfx("reagent_explosion")
	$AnimationPlayer.play("idle")
	emit_signal("exploded")


func upgrade():
	upgraded = true
	$Image/Upgraded.show()


func downgrade():
	upgraded = false
	$Image/Upgraded.hide()


func is_upgraded():
	return upgraded


func disable_dragging():
	can_drag = false
	disable_drag = true


func unrestrain_slot(target_slot):
	emit_signal("unrestrained_slot", self, target_slot)


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()


func _on_TooltipCollision_enable_tooltip():
	if (slot and slot.type != "hand") or is_drag:
		return
	tooltip_enabled = true
	var tip = ReagentManager.get_tooltip(type, upgraded, unstable, burned)
	TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)
	tip = ReagentManager.get_substitution_tooltip(type)
	if tip:
		TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, null, false, true, false)
