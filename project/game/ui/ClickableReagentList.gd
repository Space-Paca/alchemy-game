extends Control
class_name ClickableReagentList

signal reagent_pressed(reagent_name, reagent_index)

onready var grid = $ScrollContainer/GridContainer


func populate(reagent_array: Array):
	for reagent_name in reagent_array:
		var texture = ReagentDB.get_from_name(reagent_name).image
		var button = TextureButton.new()
		
		grid.add_child(button)
		button.texture_normal = texture
		button.connect("pressed", self, "_on_reagent_pressed", [reagent_name,
				button.get_index()])


func clear():
	for reagent in grid.get_children():
		grid.remove_child(reagent)


func _on_reagent_pressed(reagent_name: String, reagent_index: int):
	emit_signal("reagent_pressed", reagent_name, reagent_index)
