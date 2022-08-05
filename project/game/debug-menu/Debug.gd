extends CanvasLayer

onready var bg = $Background
onready var tween = $Tween
onready var floor_button = $Background/CenterContainer/VBoxContainer/FloorButton
onready var fps_label = $Info/FPS
onready var demo_label = $Info/Demo
onready var unlock_btn = $Background/CenterContainer/VBoxContainer/UnlockCombBtn
onready var version_label = $Info/Version
onready var id_box = $Background/CenterContainer/VBoxContainer/Event/IdBox
onready var artifact_box = $Background/CenterContainer/VBoxContainer/Artifact/TextEdit
onready var recipes_button = $Background/CenterContainer/VBoxContainer/HBoxContainer/Recipes

signal combinations_unlocked
signal battle_won
signal died
signal floor_selected(floor_number)
signal test_map_creation
signal event_pressed(id)
signal artifact_pressed(name)
signal damage_all
signal recipe_simulated(recipe)

const VERSION := "v0.7.3"
const MAX_FLOOR := 3
const PORTRAITS_PATH = "res://assets/images/ui/book/portraits/"

var allow_debugging = false
var is_demo = false
var floor_to_go := -1
var recipes_unlocked := false
var reveal_map := false
var lower_threshold := false
var give_xp := false
var custom_portrait = false
var portraits = {}
var recipes := []


func _ready():
	set_process(false)
	
	load_portraits()
	
	for arg in OS.get_cmdline_args():
		if arg == "--is_demo":
			is_demo = true
		elif arg == "--allow_debug":
			allow_debugging = true
		elif arg.find("=") > -1:
			var key_value = arg.split("=")
			var key = key_value[0]
			var value = key_value[1]
			if key == "--custom_portrait":
				if not portraits.has(value):
					push_warning("Not a valid custom portrait: " + str(value))
					custom_portrait = false
				else:
					custom_portrait = value


	version_label.text = VERSION
	demo_label.visible = is_demo
	
	floor_button.add_item("Go to floor")
	floor_button.add_separator()
	floor_button.add_item("1")
	floor_button.add_item("2")
	floor_button.add_item("3")
	
	if RecipeManager.recipes.empty():
		yield(RecipeManager, "ready")
	var i = 0
	for recipe in RecipeManager.recipes.values():
		recipes_button.add_item(recipe.id, i)
		recipes.append(recipe)


func _input(event):
	if not allow_debugging:
		return
	if event.is_action_pressed("toggle_debug"):
		bg.visible = !bg.visible
		get_tree().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.scancode == KEY_KP_SUBTRACT and not event.echo:
		emit_signal("damage_all")


func _process(_delta):
	fps_label.text = str(Engine.get_frames_per_second(), " FPS")


func set_version_visible(enable: bool):
	version_label.visible = enable


func load_portraits():
	var dir = Directory.new()
	if dir.open(PORTRAITS_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
					file_name = file_name.replace('.import', '')
					portraits[file_name.replace(".png", "")] = ResourceLoader.load(PORTRAITS_PATH + file_name)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access portraits path.")
		assert(false)


func get_portrait():
	if custom_portrait:
		return portraits[custom_portrait]
	else:
		return portraits["alchemist"]


func _on_WinBtn_pressed():
	emit_signal("battle_won")
	bg.hide()


func _on_DieBtn_pressed():
	emit_signal("died", null)
	bg.hide()


func _on_UnlockCombBtn_pressed():
	emit_signal("combinations_unlocked")
	bg.hide()


func _on_FPSButton_toggled(button_pressed):
	fps_label.visible = button_pressed
	set_process(button_pressed)


func _on_FloorButton_item_selected(id):
	if id > 1:
		floor_to_go = id - 1
		emit_signal("floor_selected", floor_to_go)
		bg.hide()


func _on_UpdateRecipesButton_pressed():
	RecipeManager.update_recipes_reagent_combinations()


func _on_RevealMap_toggled(button_pressed):
	reveal_map = button_pressed


func _on_Test_Map_Creation_pressed():
	emit_signal("test_map_creation")


func _on_RecipeThreshold_toggled(button_pressed):
	lower_threshold = button_pressed


func _on_EventButton_pressed():
	emit_signal("event_pressed", int(id_box.get_line_edit().text))
	bg.hide()


func _on_ArtifactButton_pressed():
	var name = artifact_box.text
	if ArtifactDB.has(name):
		emit_signal("artifact_pressed", artifact_box.text)
		bg.hide()
	else:
		tween.interpolate_property(artifact_box, "modulate", Color.red,
				Color.white, .5)
		tween.start()
	artifact_box.text = ""


func _on_ResetCompendium_pressed():
	Profile.reset_compendium()


func _on_ResetProgress_pressed():
	Profile.reset_progression()


func _on_GiveXp_toggled(button_pressed):
	give_xp = button_pressed


func _on_Simulate_pressed():
	emit_signal("recipe_simulated", recipes[recipes_button.selected])
	bg.hide()
