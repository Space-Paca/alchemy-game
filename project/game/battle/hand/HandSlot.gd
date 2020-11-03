extends Slot

const ALPHA_SPEED = 3

onready var frozen_effect = $CanvasLayer/FrozenEffect
var frozen = false

func _ready():
	type = "hand"

func _process(delta):
	if is_frozen():
		$FrozenImage.modulate.a = min($FrozenImage.modulate.a + ALPHA_SPEED*delta, 1)
		frozen_effect.modulate.a = min(frozen_effect.modulate.a + ALPHA_SPEED*delta, 1)
	else:
		$FrozenImage.modulate.a = max($FrozenImage.modulate.a - ALPHA_SPEED*delta, 0)
		frozen_effect.modulate.a = max(frozen_effect.modulate.a - ALPHA_SPEED*delta, 0)


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
	$CanvasLayer.offset = rect_global_position

func unfreeze():
	frozen = false
	var reagent = get_reagent()
	if reagent:
		reagent.unfreeze()
