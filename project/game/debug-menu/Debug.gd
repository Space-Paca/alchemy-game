extends CanvasLayer

onready var bg = $Background
onready var floor_button = $Background/CenterContainer/VBoxContainer/FloorButton
onready var fps_label = $Info/FPS
onready var unlock_btn = $Background/CenterContainer/VBoxContainer/UnlockCombBtn
onready var version_label = $Info/Version

signal combinations_unlocked
signal battle_won
signal floor_selected(floor_number)

const VERSION := "v0.1.2"
const MAX_FLOOR := 3

var floor_to_go := -1
var recipes_unlocked := false
var reveal_map := false


func _ready():
	set_process(false)
	version_label.text = VERSION
	
	floor_button.add_item("Go to floor")
	floor_button.add_separator()
	floor_button.add_item("1")
	floor_button.add_item("2")
	floor_button.add_item("3")


func _input(event):
	if event.is_action_pressed("toggle_debug"):
		bg.visible = !bg.visible


func _process(_delta):
	fps_label.text = str(Engine.get_frames_per_second(), " FPS")


func set_version_visible(enable: bool):
	version_label.visible = enable


func _on_WinBtn_pressed():
	emit_signal("battle_won")
	bg.hide()


func _on_UnlockCombBtn_pressed():
	emit_signal("combinations_unlocked")
	bg.hide()


func _on_FPSButton_toggled(button_pressed):
	fps_label.visible = button_pressed
	set_process(button_pressed)


func _on_MusicButton_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioManager.BGM_BUS, !button_pressed)


func _on_SFXButton_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioManager.SFX_BUS, !button_pressed)


func _on_FloorButton_item_selected(id):
	if id > 1:
		floor_to_go = id - 1
		emit_signal("floor_selected", floor_to_go)
		bg.hide()


func _on_UpdateRecipesButton_pressed():
	RecipeManager.update_recipes_reagent_combinations()


func _on_RevealMap_toggled(button_pressed):
	reveal_map = button_pressed
