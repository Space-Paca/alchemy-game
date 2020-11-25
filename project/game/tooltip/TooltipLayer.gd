extends CanvasLayer

const TOOLTIP = preload("res://game/tooltip/Tooltip.tscn")
const SCREEN_MARGIN = 10
const TOOLTIP_WIDTH = 250

var keywords = {
	"piercing damage": {
		"type": "tooltip",
		"title": "Piercing Damage",
		"text": "Piercing damage ignores shield and deals damage directly to health.",
		"title_image": preload("res://assets/images/intents/attack_piercing.png"),
	},
	"crushing damage": {
		"type": "tooltip",
		"title": "Crushing Damage",
		"text": "Crushing damage deals damage both to shield and health directly.",
		"title_image": preload("res://assets/images/intents/attack_piercing.png"),
	},
	"regular damage": {
		"type": "no_tooltip",
	},
	"healing": {
		"type": "no_tooltip",
	},
	"health": {
		"type": "no_tooltip",
	},
	"heal": {
		"type": "no_tooltip",
	},
	"shield damage": {
		"type": "no_tooltip",
	},
	"venom damage": {
		"type": "tooltip",
		"title": "Venom Damage",
		"text": "Unblocked venom damage applies poison to enemy instead of damage.",
		"title_image": preload("res://assets/images/intents/attack_venom.png"),
	},
	"drain": {
		"type": "tooltip",
		"title": "Drain",
		"text": "Deals regular damage and heals any unblocked damage.",
		"title_image": preload("res://assets/images/intents/attack_crushing.png"),
	},
	"unstable": {
		"type": "tooltip",
		"title": "Unstable",
		"text": "An unstable reagent, if used in a miscombination or not used until end of turn, explodes dealing 3 regular damage.",
		"title_image": preload("res://assets/images/status/random_status.png"),
	},
	"on fire": {
		"type": "tooltip",
		"title": "On Fire",
		"text": "This reagent, when touched, will deal 4 regular damage to user.",
		"title_image": preload("res://assets/images/status/random_status.png"),
	}
}

func _ready():
	import_status_keywords()

func import_status_keywords():
	var all_status = StatusDB.get_all_status()
	for status_name in all_status.keys():
		var status = all_status[status_name]
		keywords[status["in-text_name"]] = {
			"type": "status",
			"name": status_name
		}

func get_keywords():
	return keywords

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text, title_image, subtitle = false, play_sfx = false, expanded = false, stylize := true):
	if has_tooltip(title):
		return
	var tip = TOOLTIP.instance()
	$Tooltips.add_child(tip)
	tip.setup(title, text, title_image, subtitle, expanded, stylize)
	$Tooltips.position.x = min(pos.x + TOOLTIP_WIDTH, get_viewport().size.x-SCREEN_MARGIN) - TOOLTIP_WIDTH
	$Tooltips.position.y = pos.y

	yield(tip, "set_up")
	
	call_deferred("fade_tooltip", tip, play_sfx)
	
	for keyword in tip.get_keywords():
		if keywords.has(keyword):
			var tp_data = keywords[keyword]
			if tp_data.type == "tooltip":
				add_tooltip(pos, tp_data.title, tp_data.text, tp_data.title_image, false, true)
			elif tp_data.type == "status":
				var data = StatusDB.get_from_name(tp_data.name)
				add_tooltip(pos, data.title_name, data.description, data.image, false, true)

func fade_tooltip(tip, play_sfx):
	#Check if tip wasn't freed (trying to fix annoying tween not added error)
	if $Tooltips.is_a_parent_of(tip):
		tip.fade_in()
		if play_sfx:
			AudioManager.play_sfx("tooltip_appears")
		update_tooltips_pos()

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
	var total_height = 0
	for tip in $Tooltips.get_children():
		tip.rect_position.y = y
		var h = tip.get_height()
		y += h
		total_height += h
	$Tooltips.position.y = min($Tooltips.position.y + total_height,
							   get_viewport().size.y-SCREEN_MARGIN) - total_height
