extends Control

const MARGIN = 10

func get_title():
	return $Title.text

func setup(_title, _text):
	$Title.text = _title
	$Text.bbcode_text = _text
	update_size()

func update_size():
	$BG.rect_size.x = TooltipLayer.get_width()
	var text_h = $Text.get_size().y
	$BG.rect_size.y = $Text.rect_position.y + text_h + MARGIN

func get_width():
	return $BG.rect_size.x

func get_height():
	return $BG.rect_size.y
