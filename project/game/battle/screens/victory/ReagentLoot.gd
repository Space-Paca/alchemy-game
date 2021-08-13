extends HBoxContainer

signal reagent_looted
signal reagent_sold

onready var get_button = $GetButton
onready var sell_button = $SellButton
onready var texture_rect = $Frame/Reagent

const TEXT = "Transmute: +%d"

var reagent : String
var upgraded := false
var gold_value : int
var tooltip_enabled := false

func _ready():
	pass

func set_reagent(reagent_name: String, player: Player):
	reagent = reagent_name
	gold_value = ReagentDB.get_from_name(reagent).gold_value
	
	if player.has_artifact("cursed_pearls"):
		gold_value = gold_value/2
#		sell_label.modulate = Color(.45,0,0)
#	else:
#		sell_label.modulate = Color(1,1,1)
	
	texture_rect.texture = ReagentDB.DB[reagent].image
	sell_button.text = TEXT % gold_value

func disable_tooltip():
	tooltip_enabled = false
	TooltipLayer.clean_tooltips()


func disable_buttons():
	get_button.disabled = true
	sell_button.disabled = true


func enable_buttons():
	get_button.disabled = false
	sell_button.disabled = false


func _on_GetButton_pressed():
	get_button.disabled = true
	sell_button.disabled = true
	if tooltip_enabled:
		disable_tooltip()
	emit_signal("reagent_looted", self)


func _on_SellButton_pressed():
	sell_button.disabled = true
	if tooltip_enabled:
		disable_tooltip()
	emit_signal("reagent_sold", self)


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_TooltipCollision_disable_tooltip():
	disable_tooltip()


func _on_TooltipCollision_enable_tooltip():
	if reagent:
		tooltip_enabled = true
		var tooltip = ReagentManager.get_tooltip(reagent, upgraded)
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
								 tooltip.text, tooltip.title_image, tooltip.subtitle, true)
		tooltip = ReagentManager.get_substitution_tooltip(reagent)
		if tooltip:
			TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
								 tooltip.text, tooltip.title_image, null, false, true, false)
