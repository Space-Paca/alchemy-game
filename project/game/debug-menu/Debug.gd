extends CanvasLayer

onready var bg = $Background
onready var unlock_btn = $Background/CenterContainer/VBoxContainer/UnlockCombBtn

signal combinations_unlocked
signal battle_won


func _input(event):
	if event.is_action_pressed("toggle_debug"):
		bg.visible = !bg.visible


func _on_WinBtn_pressed():
	emit_signal("battle_won")
	bg.hide()


func _on_UnlockCombBtn_pressed():
	emit_signal("combinations_unlocked")
	bg.hide()
