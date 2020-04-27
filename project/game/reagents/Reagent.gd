extends Control

signal reached_target_pos
signal started_dragging
signal stopped_dragging
signal hovering
signal stopped_hovering

onready var texture_rect = $TextureRect

var hovering := false
var is_drag = false
var can_drag = true
var disable_drag = false
var drag_offset = Vector2(0,0)
var slot = null # current slot this reagent is in
var target_position = rect_position
var type = "none"
var image_path : String


func _ready():
	texture_rect.texture = load(image_path)

func _process(_delta):
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_drag = false
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_drag:
		rect_position = get_global_mouse_position() + drag_offset
	elif not is_drag and target_position:
		if rect_position.distance_to(target_position) > 0:
			rect_position += (target_position - rect_position)*.3
			if (target_position - rect_position).length() < 3:
				if not disable_drag:
					can_drag = true
				rect_position = target_position
				emit_signal("reached_target_pos")

func enable_dragging():
	can_drag = true
	disable_drag = false

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


func slight_shrink():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1,1), .05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func shrink():
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0,0), .15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

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
