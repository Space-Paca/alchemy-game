extends Control

signal button_pressed

onready var bg = $BG
onready var button = $BG/DownButton
onready var gold_label = $BG/CurrencyContainer/Gold/Label
onready var pearls_label = $BG/CurrencyContainer/Pearls/Label
onready var healthbar = $BG/HealthBar
onready var portrait = $BG/Portrait
onready var artifacts = $BG/Artifacts
onready var tween = $Tween
onready var gold_tooltip =  $BG/CurrencyContainer/Gold/TooltipCollision
onready var pearl_tooltip =  $BG/CurrencyContainer/Pearls/TooltipCollision

const TWEEN_DURATION = .7
const HIDDEN_POSITION = Vector2(660, -627)
const SHOWING_POSITION = Vector2(660, -400)
const PEARL_TEXTURE = preload("res://assets/images/ui/pearl.png")
const GOLD_TEXTURE = preload("res://assets/images/ui/coin.png")

var tooltip_enabled = false

func set_player(player: Player):
	# warning-ignore:return_value_discarded
	player.connect("hp_updated", self, "update_hp")
	# warning-ignore:return_value_discarded
	player.connect("gold_updated", self, "update_gold")
	# warning-ignore:return_value_discarded
	player.connect("pearls_updated", self, "update_pearls")
	
	update_values(player)


func update_values(player: Player):
	update_hp(player.hp, player.max_hp)
	update_gold(player.gold)
	update_pearls(player.pearls)


func update_hp(hp: int, max_hp: int):
	healthbar.set_life(hp, max_hp)
	portrait.update_visuals(hp, max_hp)


func update_gold(value: int):
	gold_label.text = str(value)


func update_pearls(value: int):
	pearls_label.text = str(value)


func animation_hide():
	tween.interpolate_property(bg, "rect_position", null, HIDDEN_POSITION,
			TWEEN_DURATION, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()
	
	button.disabled = true


func animation_show():
	tween.interpolate_property(bg, "rect_position", null, SHOWING_POSITION,
			TWEEN_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	button.disabled = false


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func get_tooltip_data(type):
	var tooltip = {}
	tooltip.text = ""
	if type == "gold":
		tooltip.title = "Gold"
		tooltip.title_image = GOLD_TEXTURE
		tooltip.subtitle = "Currency"
	elif type == "pearl":
		tooltip.title = "Pearls"
		tooltip.title_image = PEARL_TEXTURE
		tooltip.subtitle = "Rare Currency"
	else:
		assert(false, "Not a valid tooltip type: " + str(type))
	
	return tooltip


func _on_DownButton_pressed():
	animation_hide()
	emit_signal("button_pressed")


func _on_TooltipCollision_disable_tooltip(_type):
	if tooltip_enabled:
		remove_tooltips()


func _on_TooltipCollision_enable_tooltip(type):
	var tooltip
	if type == "gold":
		tooltip = gold_tooltip
	elif type == "pearl":
		tooltip = pearl_tooltip
	else:
		assert(false, "Not a valid tooltip type: " + str(type))
	
	tooltip_enabled = true
	var tip = get_tooltip_data(type)
	TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)
