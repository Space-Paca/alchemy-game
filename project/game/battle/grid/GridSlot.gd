extends Slot

const ALPHA_SPEED = 3

onready var reagent_hint = $MarginContainer/ReagentHint

var reagent_hint_name = null

func _ready():
	type = "grid"

func _process(delta):
	if get_reagent():
		$FullImage.modulate.a = min($FullImage.modulate.a + ALPHA_SPEED*delta, 1)
		$EmptyImage.modulate.a = max($EmptyImage.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$EmptyImage.modulate.a = min($EmptyImage.modulate.a + ALPHA_SPEED*delta, 1)
		$FullImage.modulate.a = max($FullImage.modulate.a - ALPHA_SPEED*delta, 0)

func get_width():
	return $FullImage.rect_size.x

func get_height():
	return $FullImage.rect_size.y

func set_hint(reagent_name):
	if reagent_name:
		reagent_hint.texture = ReagentDB.get_from_name(reagent_name).image
		reagent_hint_name = reagent_name
	else:
		reagent_hint.texture = null
		reagent_hint_name = null

func get_hint():
	return reagent_hint_name
