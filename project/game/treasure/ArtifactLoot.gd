extends Control

signal pressed

var artifact = null
var tooltips_enabled := false

func setup(_artifact):
	artifact = _artifact
	$Image.texture = artifact.image

func disable():
	$Button.disabled = true

func get_artifact_tooltip():
	var tooltip = {}
	tooltip.title = artifact.name
	tooltip.title_image = artifact.image
	tooltip.text = artifact.description
	
	return tooltip

func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_Button_pressed():
	emit_signal("pressed", artifact)


func _on_TooltipCollision_enable_tooltip():
	tooltips_enabled = true
	var tooltip = get_artifact_tooltip()
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, true)


func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
