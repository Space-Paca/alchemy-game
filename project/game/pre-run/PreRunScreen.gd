extends Control

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


func _on_StartButton_pressed():
	AudioManager.play_sfx("click")
	FileManager.difficulty_to_use = "normal"


func _on_BackButton_pressed():
	AudioManager.play_sfx("click")
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")
