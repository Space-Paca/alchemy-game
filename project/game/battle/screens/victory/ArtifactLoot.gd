extends HBoxContainer

signal artifact_looted

onready var get_button = $GetButton
onready var texture_rect = $TextureRect

var artifact : String
var artifact_data : Dictionary
var tooltip_enabled := false

func set_artifact(artifact_rarity: String, player: Player):
	
	var artifacts = ArtifactDB.get_artifacts(artifact_rarity)
	artifacts.shuffle()
	var artifact_name
	for artifact_id in artifacts:
		if not player.has_artifact(artifact_id):
			artifact_name = artifact_id
			break
	
	if not artifact_name:
		print("Player already has all artifacts of this rarity: " + str(artifact_rarity))
		queue_free()
		return
	
	
	artifact = artifact_name
	artifact_data = ArtifactDB.get_from_name(artifact)
		
	texture_rect.texture = artifact_data.image

func disable_tooltip():
	tooltip_enabled = false
	TooltipLayer.clean_tooltips()


func disable_buttons():
	get_button.disabled = true


func enable_buttons():
	get_button.disabled = false


func _on_GetButton_pressed():
	get_button.disabled = true
	if tooltip_enabled:
		disable_tooltip()
	emit_signal("artifact_looted", self)

func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_TooltipCollision_disable_tooltip():
	disable_tooltip()


func _on_TooltipCollision_enable_tooltip():
	if artifact:
		tooltip_enabled = true
		var tooltip = ArtifactDB.get_tooltip(artifact)
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
								 tr(tooltip.text), tooltip.title_image, tooltip.subtitle, true)
								
