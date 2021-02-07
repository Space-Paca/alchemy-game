extends Control
class_name ClickableReagentList

signal reagent_pressed(reagent_name, reagent_index)

const CLICKABLE_REAGENT = preload("res://game/ui/ClickableReagent.tscn")

onready var grid = $ScrollContainer/GridContainer


func populate(reagent_array: Array):
	for reagent in reagent_array:
		var texture = ReagentDB.get_from_name(reagent.type).image
		var button = CLICKABLE_REAGENT.instance()
		
		grid.add_child(button)
		button.setup(texture, reagent.upgraded, reagent.type)
		button.connect("pressed", self, "_on_reagent_pressed", [reagent.type,
				button.get_index(), reagent.upgraded])
		button.disable_tooltips()


func enable_tooltips():
	for reagent in grid.get_children():
		reagent.enable_tooltips()


func disable_tooltips():
	for reagent in grid.get_children():
		reagent.disable_tooltips()


func clear():
	for reagent in grid.get_children():
		grid.remove_child(reagent)

func deactivate_reagents():
	activate_reagent(-1)

func activate_reagent(index):
	for i in grid.get_child_count():
		var reagent = grid.get_child(i)
		if i == index:
			reagent.activate()
		else:
			reagent.deactivate()

func _on_reagent_pressed(reagent_name: String, reagent_index: int, upgraded: bool):
	emit_signal("reagent_pressed", reagent_name, reagent_index, upgraded)
