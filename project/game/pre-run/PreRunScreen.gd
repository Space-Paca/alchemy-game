extends Control

const BGM_STOP_SPEED = 7.0
const BACKGROUNDS = {
	"alchemist": preload("res://database/player-classes/alchemist.tres"),
	"toxicologist": preload("res://database/player-classes/toxicologist.tres"),
	"steadfast": preload("res://database/player-classes/steadfast.tres"),
}

onready var hard_text_container = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/HardContainer/HBoxContainer/VBoxContainer
onready var hard_desc_label = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/HardContainer/HBoxContainer/VBoxContainer/Description
onready var EasyButton = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/EasyContainer/HBoxContainer/DifficultyButton
onready var MediumButton = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/MediumContainer/HBoxContainer/DifficultyButton
onready var HardButton = $HBoxContainer/DifficultyContainer/MarginContainer/VBoxContainer/HardContainer/HBoxContainer/DifficultyButton
onready var bg_buttons = {
	"alchemist": $HBoxContainer/HeroContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/Hero1Button,
	"toxicologist": $HBoxContainer/HeroContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/Hero2Button,
	"steadfast": $HBoxContainer/HeroContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/Hero3Button,
}
onready var bg_labels = {
	"alchemist": $HBoxContainer/HeroContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer2/Label,
	"toxicologist": $HBoxContainer/HeroContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer2/Label2,
	"steadfast": $HBoxContainer/HeroContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer2/Label3,
}

func _ready():
	HardButton.set_process(false)
	var times_finished = Profile.get_stat("times_finished")
	for char_data in times_finished.values():
		if char_data.normal > 0:
			HardButton.disabled = false
			HardButton.set_process(true)
			hard_text_container.modulate.a = 1
			hard_desc_label.text = "DIF_HARD_DESC"
	
	for background in BACKGROUNDS:
		var unlocked = Profile.background_unlocked(background)
		bg_buttons[background].set_unlocked(unlocked)
		bg_buttons[background].set_portrait(BACKGROUNDS[background].portrait)
		bg_labels[background].text = background.to_upper() if unlocked else\
				background.to_upper() + "_COND"
		if not unlocked:
			bg_labels[background].modulate.a = .5
	
	MediumButton.skip_sfx = true
	MediumButton.pressed = true


func get_selected_background():
	for background in bg_buttons:
		if bg_buttons[background].pressed:
			return background
	push_error("No valid background selected")
	return "alchemist"


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
	FileManager.player_class = get_selected_background()
	FileManager.continue_game = false
	AudioManager.stop_bgm(BGM_STOP_SPEED)
	AudioManager.play_sfx("start_new_game")
	Transition.transition_to("res://game/dungeon/Dungeon.tscn")


func _on_BackButton_pressed():
	AudioManager.play_sfx("click")
	Transition.transition_to("res://game/main-menu/MainMenu.tscn")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")
