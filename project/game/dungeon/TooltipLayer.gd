extends CanvasLayer

const TOOLTIP = preload("res://game/tooltip/Tooltip.tscn")
const TOOLTIP_WIDTH = 220

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text, title_image, play_sfx = false):
	var tip = TOOLTIP.instance()
	tip.setup(title, text, title_image)
	$Tooltips.position.x = min(pos.x, get_viewport().size.x-TOOLTIP_WIDTH)
	$Tooltips.position.y = pos.y
	$Tooltips.add_child(tip)
	yield(tip, "setted_up")
	if play_sfx:
		AudioManager.play_sfx("tooltip_appears")
	update_tooltips_pos()

func clean_tooltips():
	for tip in $Tooltips.get_children():
		remove_tooltip(tip.get_title())

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
