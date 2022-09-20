extends TextureRect

signal entered
signal exited

onready var reagent = $MarginContainer/ReagentTexture
onready var tooltip = $TooltipCollision

const HAND_TEXTURE = preload("res://assets/images/ui/book/recipebook_slot_hand.png")
const GRID_TEXTURE = preload("res://assets/images/ui/book/recipebook_grid_slot.png")

export(Texture) var unknown_texture

var reagent_name
var tooltip_enabled
var entered = false

func _process(_dt):
	if not entered and tooltip.enabled and tooltip.entered:
		entered = true
		emit_signal("entered")
	elif entered and (not tooltip.enabled or not tooltip.entered):
		entered = false
		emit_signal("exited")


func set_mode(mode : String):
	if mode == "hand":
		texture = HAND_TEXTURE
	elif mode == "grid":
		texture = GRID_TEXTURE
	elif mode == "blank":
		texture = null
	else:
		assert(false, "Not a valid mode for reagent display:" + str(mode))


func set_reagent(_reagent_name):
	reagent_name = _reagent_name
	if reagent_name == "unknown":
		reagent.texture = unknown_texture
	elif reagent_name:
		reagent.texture = ReagentDB.get_from_name(reagent_name).image
	else:
		reagent.texture = null


func disable_tooltips():
	remove_tooltips()
	tooltip.disable()


func enable_tooltips():
	tooltip.enable()


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func cant_show_tooltip():
	return not reagent_name or reagent_name == "unknown"


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()


func _on_TooltipCollision_enable_tooltip():
	if cant_show_tooltip():
		return
	tooltip_enabled = true
	var tip = ReagentManager.get_tooltip(reagent_name, false, false, false)
	TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)
	tip = ReagentManager.get_substitution_tooltip(reagent_name)
	if tip:
		TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, null, false, true, false)
