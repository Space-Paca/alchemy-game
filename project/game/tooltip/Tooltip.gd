extends Control

const MARGIN = 20
const TITLE_IMAGE_SIZE = 24

signal setted_up

func get_title():
	return $Title.text

func setup(_title, _text, _title_image):
	modulate = Color(1,1,1,0)
	$Title.rect_size.x = 3*TooltipLayer.get_width()/4 - 2*MARGIN
	$Text.rect_size.x = TooltipLayer.get_width() - 2*MARGIN
	$Title.text = _title
	$Text.bbcode_text = _text
	if not _title_image:
		$TitleImage.hide()
	else:
		$TitleImage.texture = load(_title_image)
	
	update_size()

func update_size():
	$BG.rect_size.x = TooltipLayer.get_width()
	
	#Need to wait a frame so get_content_height gets the apropriate size
	#and title rect has increased in size to accomodate new text
	yield(TooltipLayer.get_tree(),"idle_frame")
	
	var text_h = $Text.get_content_height()
	$BG.rect_size.y = $Text.rect_position.y + text_h + MARGIN
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	#Update title size to fit textbox
	var scale = (3*TooltipLayer.get_width()/4 - 2*MARGIN)/$Title.rect_size.x
	$Title.rect_scale = Vector2(scale,scale)
	#Update title image
	var margin = 8
	$TitleImage.rect_position.x = $Title.rect_position.x + $Title.get_combined_minimum_size().x*scale + margin
	$TitleImage.rect_position.y = $Title.rect_position.y + $Title.rect_size.y*scale/2.0 - TITLE_IMAGE_SIZE/2.0
	var scale_x = TITLE_IMAGE_SIZE/float($TitleImage.texture.get_width())
	var scale_y = TITLE_IMAGE_SIZE/float($TitleImage.texture.get_height())
	$TitleImage.rect_scale = Vector2(scale_x,scale_y)
	
	emit_signal("setted_up")

func get_width():
	return $BG.rect_size.x

func get_height():
	return $BG.rect_size.y
