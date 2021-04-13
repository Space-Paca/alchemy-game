extends Control

signal button_pressed

export var hide_button := false

onready var bg = $BG
onready var button = $DownButton
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
const ARTIFACT = preload("res://game/ui/Artifact.tscn")
const DOWNBUTTON_START_Y = 130
const DOWNBUTTON_TARGET_Y = 150
const BUTTON_SPEED = 300

var tooltip_enabled = false
var mouse_over_downbutton = false


func _ready():
	if hide_button:
		button.hide()
	for artifact in artifacts.get_children():
		artifacts.remove_child(artifact)

func _process(dt):
	if mouse_over_downbutton:
		button.rect_position.y = min(button.rect_position.y + BUTTON_SPEED*dt, DOWNBUTTON_TARGET_Y)
	else:
		button.rect_position.y = max(button.rect_position.y - BUTTON_SPEED*dt, DOWNBUTTON_START_Y)

func set_player(player: Player):
	# warning-ignore:return_value_discarded
	player.connect("hp_updated", self, "update_hp")
	# warning-ignore:return_value_discarded
	player.connect("gold_updated", self, "update_gold")
	# warning-ignore:return_value_discarded
	player.connect("pearls_updated", self, "update_pearls")
	# warning-ignore:return_value_discarded
	player.connect("artifacts_updated", self, "update_artifacts")
	
	update_values(player)



func update_values(player: Player):
	update_hp(player.hp, player.max_hp)
	update_gold(player.gold)
	update_pearls(player.pearls)


func update_artifacts(player_artifacts):
	for artifact in artifacts.get_children():
		artifacts.remove_child(artifact)
	for artifact_type in player_artifacts:
		var artifact = ARTIFACT.instance()
		artifacts.add_child(artifact)
		artifact.init(artifact_type)
	
	#Wait a frame for container objects to be placed correctly
	yield(get_tree(), "idle_frame")
	for artifact in artifacts.get_children():
		artifact.update_size(.8)


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
	tween.interpolate_property(button, "rect_position:y", null, HIDDEN_POSITION,
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
	#animation_hide()
	mouse_over_downbutton = false
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


func _on_DownButton_mouse_entered():
	mouse_over_downbutton = true
	AudioManager.play_sfx("hover_playerinfo_button")


func _on_DownButton_mouse_exited():
	mouse_over_downbutton = false
