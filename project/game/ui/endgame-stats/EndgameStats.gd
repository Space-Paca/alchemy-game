extends Control

onready var menu_button = $Page2/Buttons/Menu
onready var restart_button = $Page2/Buttons/Restart
onready var xpdivider = $Page2/XPDivider
onready var compendium_progress = $Page2/CompendiumProgress
onready var unknown_compendium = $Page2/Unknown
onready var xpwarning = $Page2/XPWarning
onready var particle_container = $Page2/XPDivider/HBoxContainer/Amount/ParticleContainer

const SPEED = 3

var player : Player
var is_menu_hovered := false
var is_restart_hovered := false
var xp_divider_animation_complete := false


func _ready():
	progress_buttons_set_disabled(true)
	$Page1.show()
	$Page2.hide()
	if not UnlockManager.is_misc_unlocked("COMPENDIUM"):
		unknown_compendium.modulate.a = 1.0
		compendium_progress.modulate.a = 0.0


func _process(dt):
	if not UnlockManager.is_misc_unlocked("COMPENDIUM"):
		unknown_compendium.modulate.a = min(unknown_compendium.modulate.a + dt*SPEED, 1.0)
		compendium_progress.modulate.a = max(compendium_progress.modulate.a - dt*SPEED, 0.0)
	else:
		unknown_compendium.modulate.a = max(unknown_compendium.modulate.a - dt*SPEED, 0.0)
		compendium_progress.modulate.a = min(compendium_progress.modulate.a + dt*SPEED, 1.0)
	
	if xp_divider_animation_complete and\
			((is_menu_hovered and menu_button.disabled) or\
			(is_restart_hovered and restart_button.disabled)):
		xpwarning.modulate.a = lerp(xpwarning.modulate.a, 1, .1)
		particle_container.modulate.a = lerp(xpwarning.modulate.a, 1, .1)
	else:
		xpwarning.modulate.a = lerp(xpwarning.modulate.a, 0, .1)
		particle_container.modulate.a = lerp(xpwarning.modulate.a, 0, .1)

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
	$Page2/CompendiumProgress.enable_tooltips()
	#xpdivider.set_initial_xp_pool(10000)
	xpdivider.set_initial_xp_pool($Page1/RunStats.total_xp)
	yield(xpdivider, "setup_animation_complete")
	xp_divider_animation_complete = true
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


func _on_Restart_mouse_entered():
	is_restart_hovered = true


func _on_Menu_mouse_entered():
	is_menu_hovered = true


func _on_Restart_mouse_exited():
	is_restart_hovered = false


func _on_Menu_mouse_exited():
	is_menu_hovered = false
