extends CanvasLayer

const TOOLTIP = preload("res://game/tooltip/Tooltip.tscn")
const TOOLTIP_WIDTH = 200

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text):
	var tip = TOOLTIP.instance()
	tip.setup(title, text)
	$VBoxContainer.rect_position = pos
	$VBoxContainer.add_child(tip)
	

func remove_tooltip(title):
	for tip in $VBoxContainer.get_children():
		if tip.get_title() == title:
			$VBoxContainer.remove_child(tip)
			return
		

