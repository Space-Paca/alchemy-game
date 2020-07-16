extends Control

const SHAKE_DEGREE = 5

signal reached_target_pos
signal started_dragging
signal stopped_dragging
signal quick_place
signal hovering
signal stopped_hovering
signal finished_combine_animation
signal destroyed
signal exploded

onready var image = $Image

var stop_auto_moving := false
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
var speed_mod := 1.0
var effect_mod := 1.0
var tooltips_enabled := false
var block_tooltips := false
var upgraded := false
var unstable := false


func set_image(text):
	$Image.texture = text


func _process(_delta):
	if shake > 0:
		randomize()
		var shake_offset = Vector2(rand_range(-SHAKE_DEGREE, SHAKE_DEGREE), \
								   rand_range(-SHAKE_DEGREE, SHAKE_DEGREE))
		rect_position += shake_offset * shake

	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_drag = false
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_drag:
		rect_position = get_global_mouse_position() + drag_offset
	elif not is_drag and target_position and not stop_auto_moving:
		if rect_position.distance_to(target_position) > 0:
			rect_position += (target_position - rect_position)*.35*speed_mod
			if (target_position - rect_position).length() < 1:
				if not disable_drag:
					can_drag = true
				rect_position = target_position
				emit_signal("reached_target_pos")


func quick_place():
	emit_signal("quick_place", self)


func enable_dragging():
	can_drag = true
	disable_drag = false


func clear_tweens():
	$Tween.remove_all()


func start_shaking_and_destroy():
	$Tween.interpolate_property(self, "shake", 0, 4, .9, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(.2), "timeout")
	AudioManager.play_sfx("destroy_reagent")


func combine_animation(grid_center: Vector2, duration: float):
	var center = grid_center + -rect_size/2
	target_position = center
	stop_auto_moving = true
	$CombineTween.interpolate_property(self, "rect_position", rect_position, center, \
								duration, Tween.TRANS_BACK, Tween.EASE_IN)
	$CombineTween.interpolate_method(self, "set_grayscale", 0, 1, duration, Tween.TRANS_QUAD, Tween.EASE_IN) 
	$CombineTween.interpolate_property(self, "shake", 0, 1, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)

	$CombineTween.start()
	yield($CombineTween, "tween_all_completed")
	stop_auto_moving = false
	shake = 0.0
	emit_signal("finished_combine_animation")


func set_grayscale(value: float):
	image.material.set_shader_param("grayscale", value)


func stop_hover_effect():
	hovering = false
	slight_shrink()


func destroy():
	start_shaking_and_destroy()
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("destroyed", self)
	queue_free()


func hover_effect():
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
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1.1,1.1), .05/effect_mod, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func super_grow():
	$Tween.interpolate_property(self, "rect_scale", Vector2(0,0), Vector2(1.6,1.6), .15, Tween.TRANS_BACK, Tween.EASE_OUT)
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
	modulate = Color(3, 3, 3)


func unhighlight():
	modulate = Color.white


func start_dragging():
	disable_tooltips()
	emit_signal("started_dragging", self)


func stop_dragging():
	emit_signal("stopped_dragging", self)


func start_hovering():
	emit_signal("hovering", self)


func stop_hovering():
	emit_signal("stopped_hovering", self)


func disable():
	disable_tooltips()
	block_tooltips = true


func enable():
	block_tooltips = false

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


func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()


func get_tooltips():
	var data = ReagentManager.get_data(type)

	var text
	if not upgraded:
		text = data.tooltip % data.effect.value
	else:
		text = data.tooltip % data.effect.upgraded_value + " Boost " + \
			   data.effect.upgraded_boost.type + " recipes by " + str(data.effect.upgraded_boost.value) + "."
	if unstable:
		text += " It's unstable."

	var tooltip = {"title": data.name, "text": text, \
				   "title_image": data.image.get_path()}
	return tooltip


func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()


func _on_TooltipCollision_enable_tooltip():
	if block_tooltips or (slot and slot.type != "hand") or is_drag:
		return
	tooltips_enabled = true
	var tooltip = get_tooltips()
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, true)
