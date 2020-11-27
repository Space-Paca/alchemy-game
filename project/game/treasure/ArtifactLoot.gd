extends Control

signal pressed

var artifact = null
var artifact_id = null
var tooltips_enabled := false
var block_tooltips := false

func setup(_artifact):
	artifact = _artifact
	$Image.texture = artifact.image

func disable():
	disable_tooltips()
	block_tooltips = true
	$Button.disabled = true


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
							 tooltip.text, tooltip.title_image, tooltip.subtitle, true)


func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
