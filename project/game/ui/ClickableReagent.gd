extends TextureButton

const SPEED = 7

onready var tooltip = $TooltipCollision

var active = false
var tooltip_enabled = false
var reagent_upgraded
var reagent_type

func _ready():
	$Active.modulate.a = 0

func _process(dt):
	if active:
		$Active.modulate.a = min($Active.modulate.a + SPEED*dt, 1)
	else:
		$Active.modulate.a = max($Active.modulate.a - SPEED*dt, 0)

func activate():
	AudioManager.play_sfx("click_clickable_reagent")
	active = true
	disabled = true


func deactivate():
	active = false
	disabled = false


func setup(reagent_texture, upgraded, type):
	reagent_upgraded = upgraded
	reagent_type = type
	$Reagent.texture = reagent_texture
	if upgraded:
		$Upgraded.show()
	else:
		$Upgraded.hide()


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func disable_tooltips():
	remove_tooltips()
	$TooltipCollision.disable()


func enable_tooltips():
	tooltip.enable()


func _on_ClickableReagent_mouse_entered():
	AudioManager.play_sfx("hover_clickable_reagent")


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()


func _on_TooltipCollision_enable_tooltip():
	if not reagent_type:
		return
	tooltip_enabled = true
	var tip = ReagentManager.get_tooltip(reagent_type, reagent_upgraded, false, false)
	TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)
	tip = ReagentManager.get_substitution_tooltip(reagent_type)
	if tip:
		TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, null, false, true, false)
