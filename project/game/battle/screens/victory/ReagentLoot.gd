extends HBoxContainer

signal reagent_looted

onready var button = $Button
onready var texture_rect = $TextureRect

var reagent : String
var tooltip_enabled := false

func _ready():
	pass

func set_reagent(reagent_name: String):
	reagent = reagent_name
	texture_rect.texture = ReagentDB.DB[reagent].image

func get_tooltips():
	var tooltips = []
	if reagent:
		var data = ReagentManager.get_data(reagent)
		var tooltip = {"title": data.name, "text": data.tooltip, \
					   "title_image": data.image.get_path()}
		tooltips.append(tooltip)
	
	return tooltips

func disable_tooltip():
	tooltip_enabled = false
	TooltipLayer.clean_tooltips()

func _on_Button_pressed():
	button.disabled = true
	if tooltip_enabled:
		disable_tooltip()
	emit_signal("reagent_looted", self)

func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")

func _on_Button_button_down():
	AudioManager.play_sfx("click")

func _on_TooltipCollision_disable_tooltip():
	disable_tooltip()

func _on_TooltipCollision_enable_tooltip():
	var play_sfx = true
	tooltip_enabled = true
	for tooltip in get_tooltips():
		TooltipLayer.add_tooltip($TooltipPosition.rect_global_position, tooltip.title, \
								 tooltip.text, tooltip.title_image, play_sfx)
		play_sfx = false
