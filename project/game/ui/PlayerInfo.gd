extends Control

signal button_pressed

onready var bg = $BG
onready var button = $BG/DownButton
onready var gold_label = $BG/CurrencyContainer/Gold/Label
onready var pearls_label = $BG/CurrencyContainer/Pearls/Label
onready var healthbar = $BG/HealthBar
onready var artifacts = $BG/Artifacts
onready var tween = $Tween

const TWEEN_DURATION = .7
const HIDDEN_POSITION = Vector2(660, -627)
const SHOWING_POSITION = Vector2(660, -400)


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


func _on_DownButton_pressed():
	animation_hide()
	emit_signal("button_pressed")
