extends Control
class_name ClickableReagentList

signal reagent_pressed(reagent_name)

onready var grid = $ScrollContainer/GridContainer


func populate(reagent_array: Array):
	for reagent_name in reagent_array:
		var texture = ReagentDB.get_from_name(reagent_name).image
		var button = TextureButton.new()
		
		button.texture_normal = texture
		button.connect("pressed", self, "_on_reagent_pressed", [reagent_name])
		grid.add_child(button)

func clear():
	for reagent in grid.get_children():
		grid.remove_child(reagent)

func reset():
	for child in grid.get_children():
		child.queue_free()


func _on_reagent_pressed(reagent_name: String):
	emit_signal("reagent_pressed", reagent_name)
