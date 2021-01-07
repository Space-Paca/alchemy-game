extends Control

signal deactivate
signal activate

const HOVER_SPEED = 4
const HOVER_SCALE = 1.1

var reagent
var upgraded
var active = false
var over = false
var tooltips_enabled = false
var block_tooltips = false

func _process(dt):
	if over:
		$Button.rect_scale.x = min($Button.rect_scale.x + HOVER_SPEED*dt, HOVER_SCALE)
		$Button.rect_scale.y = min($Button.rect_scale.y + HOVER_SPEED*dt, HOVER_SCALE)  
	else:
		$Button.rect_scale.x = max($Button.rect_scale.x - HOVER_SPEED*dt, 1)  
		$Button.rect_scale.y = max($Button.rect_scale.y - HOVER_SPEED*dt, 1)  

func setup(reagent_name, _upgraded):
	$Active.hide()
	reagent = reagent_name
	upgraded = _upgraded
	var data = ReagentDB.get_from_name(reagent_name)
	
	$Button.texture_normal = data.image
	
	if upgraded:
		$Upgraded.show()
	else:
		$Upgraded.hide()

func activate():
	if active:
		return
	active = true
	$Active.show()
	emit_signal("activate")

func deactivate():
	if not active:
		return
	active = false
	$Active.hide()
	emit_signal("deactivate")

func remove_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func disable_tooltips():
	remove_tooltips()
	block_tooltips = true


func enable_tooltips():
	block_tooltips = false

func _on_Button_mouse_entered():
	if not active:
		over = true
		AudioManager.play_sfx("hover_reagent")


func _on_Button_mouse_exited():
	over = false

func _on_Button_pressed():
	if not active:
		activate()


func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = ReagentManager.get_tooltip(reagent, upgraded, false, false)
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, tooltip.subtitle, true)
	tooltip = ReagentManager.get_substitution_tooltip(reagent)
	if tooltip:
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, null, false, true, false)


func _on_TooltipCollision_disable_tooltip():
	remove_tooltips()
