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
	"evasion": {
		"type": "status",
		"name": "evasion"
	},
	"retaliate": {
		"type": "status",
		"name": "retaliate"
	},
	"temporary strength": {
		"type": "status",
		"name": "temp_strength"
	},
	"permanent strength": {
		"type": "status",
		"name": "perm_strength"
	},
	"divider": {
		"type": "status",
		"name": "divider"
	},
	"revenge": {
		"type": "status",
		"name": "revenge"
	},
	"rage": {
		"type": "status",
		"name": "rage"
	},
	"minor restriction": {
		"type": "status",
		"name": "restrict_minor"
	},
	"major restriction": {
		"type": "status",
		"name": "restrict_major"
	},
	"minion": {
		"type": "status",
		"name": "minion"
	},
	"tough": {
		"type": "status",
		"name": "tough"
	},
	"freeze": {
		"type": "status",
		"name": "freeze"
	},
	"time bomb": {
		"type": "status",
		"name": "time_bomb"
	},
	"curse": {
		"type": "status",
		"name": "curse"
	},
	"parasite": {
		"type": "status",
		"name": "parasite"
	},
	"weak": {
		"type": "status",
		"name": "weak"
	},
	"piercing damage": {
		"type": "tooltip",
		"title": "Piercing Damage",
		"text": "Piercing damage ignores shield and deals damage directly to health.",
		"title_image": preload("res://assets/images/enemies/intents/attack_piercing.png"),
	},
	"drain": {
		"type": "tooltip",
		"title": "Drain",
		"text": "Deals regular damage and heals any unblocked damage.",
		"title_image": preload("res://assets/images/enemies/intents/attack_crushing.png"),
	},
	"unstable": {
		"type": "tooltip",
		"title": "Unstable",
		"text": "An unstable reagent, if not used properly or until end of turn, explodes dealing 3 regular damage.",
		"title_image": preload("res://assets/images/status/random_status.png"),
	},
}

var status_db = preload("res://game/character/Status.gd").new()

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text, title_image, play_sfx = false, expanded = false, stylize := true):
	if has_tooltip(title):
		return
	var tip = TOOLTIP.instance()
	$Tooltips.add_child(tip)
	tip.setup(title, text, title_image, expanded, stylize)
	$Tooltips.position.x = min(pos.x, get_viewport().size.x-TOOLTIP_WIDTH)
	$Tooltips.position.y = pos.y
	yield(tip, "set_up")
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
