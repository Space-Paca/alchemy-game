extends Control

signal pressed

const HOVER_SPEED = 4

var artifact = null
var artifact_id = null
var tooltips_enabled := false
var block_tooltips := false
var mouse_over := false


func _process(dt):
	if mouse_over:
		$Image.rect_scale.x = min($Image.rect_scale.x + HOVER_SPEED*dt, 1.15)
		$Image.rect_scale.y = min($Image.rect_scale.y + HOVER_SPEED*dt, 1.15)
	else:
		$Image.rect_scale.x = max($Image.rect_scale.x - HOVER_SPEED*dt, 1.0)
		$Image.rect_scale.y = max($Image.rect_scale.y - HOVER_SPEED*dt, 1.0)


func setup(_artifact, rarity):
	artifact = _artifact
	$Image.texture = artifact.image
	if rarity == "common":
		$Particles2D.process_material.hue_variation = -1
	elif rarity == "uncommon":
		$Particles2D.process_material.hue_variation = -.25
	elif rarity == "rare":
		$Particles2D.process_material.hue_variation = .25
	else:
		push_error("Not a valid rarity: " + str(rarity))

func disable():
	disable_tooltips()
	block_tooltips = true
	$Button.disabled = true

func collected():
	var offset = 200
	$Tween.interpolate_property(self, "rect_position:y", rect_position.y, rect_position.y - offset, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	
func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_Button_pressed():
	emit_signal("pressed", artifact)

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = ArtifactDB.get_tooltip(artifact.id)
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tr(tooltip.text), tooltip.title_image, tooltip.subtitle, true)


func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()


func _on_Button_mouse_entered():
	mouse_over = true


func _on_Button_mouse_exited():
	mouse_over = false
