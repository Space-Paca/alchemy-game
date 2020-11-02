extends Control

signal button_pressed

onready var bg = $BG
onready var button = $BG/DownButton
onready var gold_label = $BG/CurrencyContainer/Gold/Label
onready var gems_label = $BG/CurrencyContainer/Gems/Label
onready var healthbar = $BG/HealthBar
onready var artifacts = $BG/Artifacts
onready var tween = $Tween

const TWEEN_DURATION = .7
const HIDDEN_POSITION = Vector2(660, -627)
const SHOWING_POSITION = Vector2(660, -400)


func _ready():
	pass


func update_hp(hp: int, max_hp: int):
	healthbar.set_life(hp, max_hp)


func update_gold(value: int):
	gold_label.text = str(value)


func update_gems(value: int):
	gems_label.text = str(value)


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
