tool
extends Node2D
class_name MapPosition

export(Array, NodePath) var children : Array

var node : MapNode


func _ready():
	if Engine.editor_hint:
		var label : Label
		if get_child_count():
			label = get_child(0)
		else:
			label = Label.new()
			add_child(label)
		label.text = name
