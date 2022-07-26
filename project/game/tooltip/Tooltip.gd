extends Control

const MARGIN_X = 35
const MARGIN_Y = 38
const SEPARATION_TITLE_SUBTITLE = 2
const SEPARATION_TITLE_TEXT = 9
const SEPARATION_TITLE_IMAGE = 15
const TITLE_IMAGE_SIZE = 48
const FONT_NORMAL = preload("res://assets/fonts/TooltipFontNormal.tres")
const FONT_BIG = preload("res://assets/fonts/TooltipFontBig.tres")
const FONT_TITLE_NORMAL = preload("res://assets/fonts/TooltipTitleFontNormal.tres")
const FONT_TITLE_BIG = preload("res://assets/fonts/TooltipTitleFontBig.tres")
const FONT_SUBTITLE_NORMAL = preload("res://assets/fonts/TooltipSubtitleFontNormal.tres")
const FONT_SUBTITLE_BIG = preload("res://assets/fonts/TooltipSubtitleFontBig.tres")

signal set_up

func get_title():
	return $Title.text

func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func setup(_title, _text, _title_image, _subtitle = false, expanded = false, stylize = true):
	if Profile.get_option("large_ui"):
		$Text.add_font_override("normal_font", FONT_BIG)
		$Title.add_font_override("font", FONT_TITLE_BIG)
		$Subtitle.add_font_override("font", FONT_SUBTITLE_BIG)
	else:
		$Text.add_font_override("normal_font", FONT_NORMAL)
		$Title.add_font_override("font", FONT_TITLE_NORMAL)
		$Subtitle.add_font_override("font", FONT_SUBTITLE_NORMAL)
	
	modulate = Color(1,1,1,0)
	$Title.rect_position.y = MARGIN_Y
	$Title.rect_position.x = MARGIN_X
	$Title.text = _title
	$Text.rect_position.x = MARGIN_X
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
		$TitleImageBG.hide()
	else:
		if _title_image is String:
			$TitleImageBG/TitleImage.texture = load(_title_image)
		else:
			$TitleImageBG/TitleImage.texture = _title_image
	
	update_size()

func stylize_text(text):
	#Color keywords
	for keyword in TooltipLayer.get_keywords():
		text = text.replace(tr(keyword), "[color=lime]" + tr(keyword) + "[/color]")
	
	#Color numbers
	#It works with two equal numbers now! (*/ω＼*)
	var regex = RegEx.new()
	regex.compile("(\\d+%*)")
	var offset = 0
	while offset < text.length():
		var result = regex.search(text, offset)
		if result:
			text = text.insert(result.get_end(1), "[/color]")
			text = text.insert(result.get_start(1), "[color=fuchsia]")
			offset = result.get_end(1) + "[color=fuchsia]".length()
		else:
			break

	return text

func update_size():
	#Need to wait a frame so get_content_height gets the apropriate size
	#and title rect has increased in size to accomodate new text
	yield(TooltipLayer.get_tree(),"idle_frame") 
	
	
	#Update title image
	$TitleImageBG.rect_position.x = $Title.rect_position.x + $Title.get_combined_minimum_size().x + SEPARATION_TITLE_IMAGE
	$TitleImageBG.rect_position.y = $Title.rect_position.y + $Title.rect_size.y/2.0 - $TitleImageBG.rect_size.x/2.0
	var scale
	var w = $TitleImageBG/TitleImage.texture.get_width()
	var h = $TitleImageBG/TitleImage.texture.get_height()
	if w >= h:
		scale = TITLE_IMAGE_SIZE/float(w)
	else:
		scale = TITLE_IMAGE_SIZE/float(h)
	$TitleImageBG/TitleImage.rect_scale = Vector2(scale,scale)
	$TitleImageBG/TitleImage.rect_position.x = $TitleImageBG.rect_size.x/2 - w*scale/2
	$TitleImageBG/TitleImage.rect_position.y = $TitleImageBG.rect_size.y/2 - h*scale/2
	
	$BG.rect_size.x = $TitleImageBG.rect_position.x + $TitleImageBG.rect_size.x + MARGIN_X
	$Text.rect_size.x = $BG.rect_size.x - 2*MARGIN_X
	
	#Update subtitle
	$Subtitle.rect_position.y = $Title.rect_position.y + $Title.rect_size.y + SEPARATION_TITLE_SUBTITLE
	if $Subtitle.text == "":
		$Text.rect_position.y = $Title.rect_position.y + $Title.rect_size.y + SEPARATION_TITLE_TEXT
	else:
		$Text.rect_position.y = $Subtitle.rect_position.y + $Subtitle.rect_size.y + SEPARATION_TITLE_TEXT
	
	#Yield one more free to accomodate text to its final form
	yield(TooltipLayer.get_tree(),"idle_frame") 
	
	var text_h = SEPARATION_TITLE_TEXT + $Text.get_content_height() if $Text.bbcode_text != "" else 0
	var sub_h = SEPARATION_TITLE_SUBTITLE + $Subtitle.rect_size.y if $Subtitle.text != "" else 0
	$BG.rect_size.y = $Title.rect_position.y + $Title.rect_size.y + sub_h + text_h + MARGIN_Y
	
	emit_signal("set_up")

func get_width():
	return $BG.rect_size.x

func get_height():
	return $BG.rect_size.y

func get_keywords():
	var keywords = []
	for keyword in TooltipLayer.get_keywords():
		if $Text.bbcode_text.find(tr(keyword)) != -1:
			keywords.append(keyword)
	return keywords
