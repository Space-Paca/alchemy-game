extends Slot

const ALPHA_SPEED = 3

var frozen = false

func _ready():
	type = "hand"

func _process(delta):
	if not is_frozen():
		$RegularImage.modulate.a = min($RegularImage.modulate.a + ALPHA_SPEED*delta, 1)
		$FrozenImage.modulate.a = max($FrozenImage.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$FrozenImage.modulate.a = min($FrozenImage.modulate.a + ALPHA_SPEED*delta, 1)
		$RegularImage.modulate.a = max($RegularImage.modulate.a - ALPHA_SPEED*delta, 0)

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
