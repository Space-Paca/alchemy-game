extends Control

onready var menu_button = $Page2/Buttons/Menu
onready var restart_button = $Page2/Buttons/Restart
onready var xpdivider = $Page2/XPDivider

var player : Player


func _ready():
	progress_buttons_set_disabled(true)
	$Page1.show()
	$Page2.hide()


func set_player(p: Player):
	player = p
	$Page1/RunStats.set_player(p)
	$Page1/PostMortem.set_player(p)
	$Page2/CompendiumProgress.set_player(p)


func progress_buttons_set_disabled(d: bool):
	menu_button.disabled = d
	restart_button.disabled = d


func _on_Menu_pressed():
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/main-menu/MainMenu.tscn")
	Transition.end_transition()

func _on_Restart_pressed():
	Transition.begin_transition()
	yield(Transition, "screen_dimmed")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game/dungeon/Dungeon.tscn")
	Transition.end_transition()


func _on_Next_pressed():
	$Page1.hide()
	$Page2.show()
	xpdivider.set_initial_xp_pool($Page1/RunStats.total_xp)
	yield(xpdivider, "setup_animation_complete")
	progress_buttons_set_disabled(xpdivider.can_apply_xp())


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_Button_mouse_entered():
	AudioManager.play_sfx("hover_button")


func _on_XPDivider_applied_xp():
	progress_buttons_set_disabled(xpdivider.can_apply_xp())


func _on_RunStats_animation_finished():
	$Page1/Next.disabled = false


func _on_XPDivider_content_unlocked(unlock_data):
	$UnlockablePopup.setup(unlock_data)
	$UnlockablePopup.appear()


func _on_UnlockablePopup_closed():
	$UnlockablePopup.hide()
	$Page2/XPDivider.emit_signal("unlock_popup_closed")
