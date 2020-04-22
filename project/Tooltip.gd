extends Control

func get_title():
	return $Title.text

func setup(title, text):
	$Title.text = title
	$Text.text = text
	update_size()

func update_size():
	pass

func get_width():
	return $BG.rect_size.x

func get_height():
	return $BG.rect_size.y
