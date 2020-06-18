extends CanvasLayer

const TOOLTIP = preload("res://game/tooltip/Tooltip.tscn")
const TOOLTIP_WIDTH = 250
const KEYWORDS = {
	"guard up": {
		"type": "status",
		"name": "guard_up"
	},
	"poison": {
		"type": "status",
		"name": "poison"
	},
	"dodge": {
		"type": "status",
		"name": "dodge"
	},
	"temporary strength": {
		"type": "status",
		"name": "temp_strength"
	},
	"permanent strength": {
		"type": "status",
		"name": "perm_strength"
	},
	"piercing damage": {
		"type": "tooltip",
		"title": "Piercing Damage",
		"text": "Piercing damage ignores shield and deals damage directly to health.",
		"title_image": preload("res://assets/images/enemies/intents/attack_piercing.png"),
	},
}

var status_db = preload("res://game/character/Status.gd").new()

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text, title_image, play_sfx = false, expanded = false):
	if has_tooltip(title):
		return
	var tip = TOOLTIP.instance()
	$Tooltips.add_child(tip)
	tip.setup(title, text, title_image, expanded)
	$Tooltips.position.x = min(pos.x, get_viewport().size.x-TOOLTIP_WIDTH)
	$Tooltips.position.y = pos.y
	yield(tip, "setted_up")
	if play_sfx:
		AudioManager.play_sfx("tooltip_appears")
	update_tooltips_pos()
	
	for keyword in tip.get_keywords():
		if KEYWORDS.has(keyword):
			var tp_data = KEYWORDS[keyword]
			if tp_data.type == "tooltip":
				add_tooltip(pos, tp_data.title, tp_data.text, tp_data.title_image, false, true)
			elif tp_data.type == "status":
				tp_data = status_db.STATUS_TOOLTIPS[tp_data.name]
				add_tooltip(pos, tp_data.title, tp_data.text, tp_data.title_image, false, true)

func has_tooltip(title):
	for tooltip in $Tooltips.get_children():
		if tooltip.get_title() == title:
			return true
	return false

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
