extends HBoxContainer

signal reagent_looted

onready var button = $Button
onready var texture_rect = $TextureRect

var reagent : String

func _ready():
	pass
	

func set_reagent(reagent_name: String):
	reagent = reagent_name
	texture_rect.texture = load(ReagentDB.DB[reagent]["image"])


func _on_Button_pressed():
	AudioManager.play_sfx("click")
	button.disabled = true
	emit_signal("reagent_looted", self)
