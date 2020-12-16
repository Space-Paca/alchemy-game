extends CanvasLayer

onready var bg = $Background

const AUDIO_FILTER = preload("res://game/pause/pause_audio_filter.tres")

var paused := false


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		toggle_pause()


func toggle_pause():
	set_pause(!paused)


func set_pause(p: bool):
	paused = p
	get_tree().paused = p
	bg.visible = p
	if p:
		AudioServer.add_bus_effect(0, AUDIO_FILTER)
	else:
		AudioServer.remove_bus_effect(0, 0)


func _on_Resume_pressed():
	toggle_pause()


func _on_Return_pressed():
	set_pause(false)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/main-menu/MainMenu.tscn")


func _on_Exit_pressed():
	get_tree().quit()
