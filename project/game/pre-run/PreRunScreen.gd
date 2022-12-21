extends Control

const BGM_STOP_SPEED = 7.0

onready var HardContainer = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/HardContainer
onready var EasyButton = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/EasyContainer/HBoxContainer/DifficultyButton
onready var MediumButton = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/MediumContainer/HBoxContainer/DifficultyButton
onready var HardButton = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/HardContainer/HBoxContainer/DifficultyButton


func _ready():
	HardContainer.hide()
	var times_finished = Profile.get_stat("times_finished")
	for char_data in times_finished.values():
		if char_data.normal > 0:
			HardContainer.show()
	
	MediumButton.pressed = true


func get_selected_difficulty():
	if EasyButton.pressed:
		return "easy"
	elif MediumButton.pressed:
		return "normal"
	elif HardButton.pressed:
		return "hard"
	else:
		push_error("No valid difficulty selected")
		return "normal"
	
func _on_StartButton_pressed():
	FileManager.difficulty_to_use = get_selected_difficulty()
	FileManager.continue_game = false
	AudioManager.stop_bgm(BGM_STOP_SPEED)
	AudioManager.play_sfx("start_new_game")
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


func _on_BackButton_pressed():
	AudioManager.play_sfx("click")
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")
