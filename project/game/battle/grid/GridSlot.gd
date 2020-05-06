extends Slot

const ALPHA_SPEED = 3

onready var reagent_hint = $MarginContainer/ReagentHint

func _ready():
	$FullImage.modulate.a = 0
	$EmptyImage.modulate.a = 1

func _process(delta):
	if get_reagent():
		$FullImage.modulate.a = min($FullImage.modulate.a + ALPHA_SPEED*delta, 1)
		$EmptyImage.modulate.a = max($FullImage.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$EmptyImage.modulate.a = min($FullImage.modulate.a + ALPHA_SPEED*delta, 1)
		$FullImage.modulate.a = max($FullImage.modulate.a - ALPHA_SPEED*delta, 0)

func set_hint(reagent_name):
	if reagent_name:
		reagent_hint.texture = load(ReagentDB.get_from_name(reagent_name).image)
	else:
		reagent_hint.texture = null
