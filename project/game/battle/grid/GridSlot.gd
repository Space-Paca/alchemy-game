extends Slot

const ALPHA_SPEED = 3

onready var reagent_hint = $MarginContainer/ReagentHint

func _process(delta):
	if get_reagent():
		$FullImage.modulate.a = min($FullImage.modulate.a + ALPHA_SPEED*delta, 1)
		$EmptyImage.modulate.a = max($EmptyImage.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$EmptyImage.modulate.a = min($EmptyImage.modulate.a + ALPHA_SPEED*delta, 1)
		$FullImage.modulate.a = max($FullImage.modulate.a - ALPHA_SPEED*delta, 0)

func set_hint(reagent_name):
	if reagent_name:
		reagent_hint.texture = ReagentDB.get_from_name(reagent_name).image
	else:
		reagent_hint.texture = null
