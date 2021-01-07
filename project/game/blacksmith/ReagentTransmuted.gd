extends Control

signal deactivate
signal activate

const HOVER_SPEED = 4
const HOVER_SCALE = 1.1

var reagent
var upgraded
var active = false
var over = false

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


func _on_Button_mouse_entered():
	if not active:
		over = true
		AudioManager.play_sfx("hover_reagent")


func _on_Button_mouse_exited():
	over = false

func _on_Button_pressed():
	if not active:
		activate()
