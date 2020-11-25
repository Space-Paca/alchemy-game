extends Control

const MARGIN_X = 35
const MARGIN_Y = 34
const SEPARATION_TITLE_SUBTITLE = 4
const SEPARATION_TITLE_TEXT = 12
const TITLE_IMAGE_SIZE = 32

signal set_up

func get_title():
	return $Title.text

func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func setup(_title, _text, _title_image, _subtitle = false, expanded = false, stylize = true):
	modulate = Color(1,1,1,0)
	$Title.rect_size.x = 3*TooltipLayer.get_width()/4 - 2*MARGIN_X
	$Title.rect_position.y = MARGIN_Y
	$Title.rect_position.x = MARGIN_X
	$Title.text = _title
	$Text.rect_size.x = TooltipLayer.get_width() - 2*MARGIN_X
	$Text.rect_position.x = MARGIN_X
	$Subtitle.rect_size.x = TooltipLayer.get_width() - 2*MARGIN_X
	$Subtitle.rect_position.x = MARGIN_X
	
	if _subtitle:
		$Subtitle.text = _subtitle
	else:
		$Subtitle.text = ""
		$Text.rect_position.y -= 40
	
	if stylize:
		$Text.bbcode_text = stylize_text(_text)
	else:
		#Don't stylize in case of bags tooltips (it have images that glitches style)
		#╬(▔皿▔)╯
		$Text.bbcode_text = _text
	
	if expanded:
		$BG.modulate = Color(.65,1,.65,1)
	else:
		$BG.modulate = Color(1,1,1,1)

	if not _title_image:
		$TitleImage.hide()
	else:
		if _title_image is String:
			$TitleImage.texture = load(_title_image)
		else:
			$TitleImage.texture = _title_image
	
	update_size()

func stylize_text(text):
	#Color keywords
	for keyword in TooltipLayer.get_keywords():
		text = text.replace(keyword, "[color=lime]" + keyword + "[/color]")
	
	#Color numbers
	#This could/will probably not work properly if there is two equal nubmers on the text
	#But we'll deal with this later (。・ω・。)
	var regex = RegEx.new()
	regex.compile("(\\d+%*)")
	var offset = 0
	while offset < text.length():
		var result = regex.search(text, offset)
		if result:
			var n = result.get_string(1)
			text = text.replace(n, "[color=fuchsia]"+n+"[/color]")
			offset = result.get_end(1) + "[color=fuchsia]".length()
		else:
			break

	return text

func update_size():
	$BG.rect_size.x = max(TooltipLayer.get_width(), $Title.rect_size.x)
	
	#Need to wait a frame so get_content_height gets the apropriate size
	#and title rect has increased in size to accomodate new text
	yield(TooltipLayer.get_tree(),"idle_frame") 
	
	var text_h = SEPARATION_TITLE_TEXT + $Text.get_content_height() if $Text.bbcode_text != "" else 0
	var sub_h = SEPARATION_TITLE_SUBTITLE + $Subtitle.rect_size.y if $Subtitle.text != "" else 0
	$BG.rect_size.y = $Title.rect_position.y + $Title.rect_size.y + sub_h + text_h + MARGIN_Y
	
	#Update title size to fit textbox
	var scale = (3*$BG.rect_size.x/4 - 2*MARGIN_X)/$Title.rect_size.x
	$Title.rect_scale = Vector2(scale,scale)
	#Update title image
	var margin = 8
	$TitleImage.rect_position.x = $Title.rect_position.x + $Title.get_combined_minimum_size().x*scale + margin
	$TitleImage.rect_position.y = $Title.rect_position.y + $Title.rect_size.y*scale/2.0 - TITLE_IMAGE_SIZE/2.0
	var scale_x = TITLE_IMAGE_SIZE/float($TitleImage.texture.get_width())
	var scale_y = TITLE_IMAGE_SIZE/float($TitleImage.texture.get_height())
	$TitleImage.rect_scale = Vector2(scale_x,scale_y)
	
	if $Subtitle.text == "":
		$Text.rect_position.y = $Title.rect_position.y + $Title.rect_size.y*scale + SEPARATION_TITLE_TEXT
	else:
		$Text.rect_position.y = $Subtitle.rect_position.y + $Subtitle.rect_size.y + SEPARATION_TITLE_TEXT

	$BG.rect_size.y = $Text.rect_position.y + text_h + MARGIN_Y
	
	emit_signal("set_up")

func get_width():
	return $BG.rect_size.x

func get_height():
	return $BG.rect_size.y

func get_keywords():
	var keywords = []
	for keyword in TooltipLayer.get_keywords():
		if $Text.bbcode_text.find(keyword) != -1:
			keywords.append(keyword)
	return keywords
