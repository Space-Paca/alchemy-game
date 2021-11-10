extends Slot

const ALPHA_SPEED = 3
const HIGHLIGHT_SPEED = 4

onready var frozen_effect = $CanvasLayer/FrozenEffect

var frozen := false
var highlighted := false

func _ready():
	type = "hand"


func _process(delta):
	if is_frozen():
		$CanvasLayer.offset = rect_global_position
		$FrozenImage.modulate.a = min($FrozenImage.modulate.a + ALPHA_SPEED*delta, 1)
		frozen_effect.modulate.a = min(frozen_effect.modulate.a + ALPHA_SPEED*delta, 1)
	else:
		$FrozenImage.modulate.a = max($FrozenImage.modulate.a - ALPHA_SPEED*delta, 0)
		frozen_effect.modulate.a = max(frozen_effect.modulate.a - ALPHA_SPEED*delta, 0)
	
	if highlighted:
		modulate.r = max(modulate.r - HIGHLIGHT_SPEED*delta, Color.green.r)
		modulate.g = max(modulate.g - HIGHLIGHT_SPEED*delta, Color.green.g)
		modulate.b = max(modulate.b - HIGHLIGHT_SPEED*delta, Color.green.b)
	else:
		modulate.r = min(modulate.r + HIGHLIGHT_SPEED*delta, 1)
		modulate.g = min(modulate.g + HIGHLIGHT_SPEED*delta, 1)
		modulate.b = min(modulate.b + HIGHLIGHT_SPEED*delta, 1)


func remove_reagent(emit := true):
	.remove_reagent(emit)
	unhighlight()


func error_effect():
	# warning-ignore:return_value_discarded
	$Tween.interpolate_property(self, "modulate", Color.red, Color.white,
			.5, Tween.TRANS_SINE, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	$Tween.start()


func highlight():
	highlighted = true


func unhighlight():
	highlighted = false


func hide_effects():
	frozen_effect.hide()


func show_effects():
	frozen_effect.show()


func is_frozen():
	return frozen


func freeze():
	frozen = true
	var reagent = get_reagent()
	if reagent:
		reagent.freeze()

func unfreeze():
	frozen = false
	var reagent = get_reagent()
	if reagent:
		reagent.unfreeze()
