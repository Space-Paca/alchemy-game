extends CanvasLayer

const TOOLTIP = preload("res://game/tooltip/Tooltip.tscn")
const TOOLTIP_WIDTH = 200

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text):
	var tip = TOOLTIP.instance()
	tip.setup(title, text)
	$Tooltips.position = pos
	$Tooltips.add_child(tip)
	update_tooltips_pos()

func remove_tooltip(title):
	for tip in $Tooltips.get_children():
		if tip.get_title() == title:
			$Tooltips.remove_child(tip)
			return
		

func update_tooltips_pos():
	var y = 0
	for tip in $Tooltips.get_children():
		tip.rect_position.y = y
		y += tip.get_height()
