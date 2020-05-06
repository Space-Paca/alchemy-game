extends Control

const SHAKE_DEGREE = 5

signal reached_target_pos
signal started_dragging
signal stopped_dragging
signal hovering
signal stopped_hovering
signal finished_combine_animation

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
			rect_position += (target_position - rect_position)*.3
			if (target_position - rect_position).length() < 1:
				if not disable_drag:
					can_drag = true
				rect_position = target_position
				emit_signal("reached_target_pos")


func enable_dragging():
	can_drag = true
	disable_drag = false

func clear_tweens():
	$Tween.remove_all()

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
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1.1,1.1), .05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func grow():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .5, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()

func grow_and_shrink():
	shake = 0.0
	$Tween.interpolate_method(self, "set_grayscale", 1.0, 0.0, .2, Tween.TRANS_LINEAR, Tween.EASE_IN) 
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0,0), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func slight_shrink():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func shrink():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0,0), .15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func highlight():
	modulate = Color.black


func unhighlight():
	modulate = Color.white


func start_dragging():
	emit_signal("started_dragging", self)


func stop_dragging():
	emit_signal("stopped_dragging", self)


func start_hovering():
	emit_signal("hovering", self)


func stop_hovering():
	emit_signal("stopped_hovering", self)


func disable_dragging():
	can_drag = false
	disable_drag = true
