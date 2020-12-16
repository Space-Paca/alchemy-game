extends CanvasLayer

onready var bg = $Background

var paused := false


func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		toggle_pause()


func toggle_pause():
	paused = !paused
	get_tree().paused = paused
	bg.visible = paused


func _on_Resume_pressed():
	toggle_pause()


func _on_Return_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://game/main-menu/MainMenu.tscn")


func _on_Exit_pressed():
	get_tree().quit()
