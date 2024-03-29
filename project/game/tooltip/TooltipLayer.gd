extends CanvasLayer

const TOOLTIP = preload("res://game/tooltip/Tooltip.tscn")
const SCREEN_MARGIN = 10
const TOOLTIP_WIDTH = 250

var keywords = [
	{
		"keyword": "PIERCING_DAMAGE",
		"type": "tooltip",
		"title": "PIERCING_DAMAGE_TITLE",
		"text": "PIERCING_DAMAGE_DESC",
		"title_image": preload("res://assets/images/intents/attack_piercing.png"),
	},
	{
		"keyword": "CRUSHING_DAMAGE",
		"type": "tooltip",
		"title": "CRUSHING_DAMAGE_TITLE",
		"text": "CRUSHING_DAMAGE_DESC",
		"title_image": preload("res://assets/images/intents/attack_piercing.png"),
	},
	{
		"keyword": "POISON_DAMAGE",
		"type": "tooltip",
		"title": "POISON_DAMAGE_TITLE",
		"text": "POISON_DAMAGE_DESC",
		"title_image": preload("res://assets/images/status/poison.png"),
	},
	{
		"keyword": "REGULAR_DAMAGE",
		"type": "no_tooltip",
	},
	{
		"keyword": "ELITE",
		"type": "no_tooltip",
	},
	{
		"keyword": "KEYWORD_ELITE",
		"type": "no_tooltip",
	},
	{
		"keyword": "SHIELD",
		"type": "no_tooltip",
	},
	{
		"keyword": "UNBLOCKED",
		"type": "no_tooltip",
	},
	{
		"keyword": "HEALING",
		"type": "no_tooltip",
	},
	{
		"keyword": "HEALTH",
		"type": "no_tooltip",
	},
	{
		"keyword": "HEALS",
		"type": "no_tooltip",
	},
	{
		"keyword": "HEAL",
		"type": "no_tooltip",
	},
	{
		"keyword": "EXILES",
		"type": "tooltip",
		"title": "EXILE_TITLE",
		"text": "EXILE_DESC",
		"title_image": preload("res://assets/images/ui/exiled_reagent.png"),
	},
	{
		"keyword": "VENOM_DAMAGE",
		"type": "tooltip",
		"title": "VENOM_DAMAGE_TITLE",
		"text": "VENOM_DAMAGE_DESC",
		"title_image": preload("res://assets/images/intents/attack_venom.png"),
	},
	{
		"keyword": "DRAIN_2",
		"type": "tooltip",
		"title": "DRAIN_TITLE",
		"text": "DRAIN_DESC",
		"title_image": preload("res://assets/images/intents/attack_drain.png"),
	},
	{
		"keyword": "DRAIN",
		"type": "tooltip",
		"title": "DRAIN_TITLE",
		"text": "DRAIN_DESC",
		"title_image": preload("res://assets/images/intents/attack_drain.png"),
	},
	{
		"keyword": "UNSTABLE",
		"type": "tooltip",
		"title": "UNSTABLE_TITLE",
		"text": "UNSTABLE_DESC",
		"title_image": preload("res://assets/images/status/random_status.png"),
	},
	{
		"keyword": "UNSTABLE_PLURAL",
		"type": "tooltip",
		"title": "UNSTABLE_TITLE",
		"text": "UNSTABLE_DESC",
		"title_image": preload("res://assets/images/status/random_status.png"),
	},
	{
		"keyword": "ON_FIRE",
		"type": "tooltip",
		"title": "ON_FIRE_TITLE",
		"text": "ON_FIRE_DESC",
		"title_image": preload("res://assets/images/ui/burned_reagent.png"),
	},
	{
		"keyword": "ABSORB",
		"type": "tooltip",
		"title": "ABSORB_TITLE",
		"text": "ABSORB_DESC",
		"title_image": preload("res://assets/images/ui/absorb.png"),
	},
]


func _ready():
	import_status_keywords()
	import_reagents_keywords()
	sort_keywords()


func import_status_keywords():
	var all_status = StatusDB.get_all_status()
	for status_name in all_status.keys():
		var status = all_status[status_name]
		keywords.append({
			"keyword": status.title_name,
			"type": "status",
			"name": status_name
		})


func import_reagents_keywords():
	var all_reagents = ReagentDB.get_reagents()
	for reagent_name in all_reagents.keys():
		var reagent_data =  all_reagents[reagent_name]
		keywords.append({
			"keyword": reagent_data.name,
			"type": "reagent",
			"name": reagent_name
		})

#Sorts keywords by name length bigger strings first
func sort_keywords():
	keywords.sort_custom(self, "sort_by_name_length")


func sort_by_name_length(a, b):
	return tr(b.keyword).length() < tr(a.keyword).length()

func get_keywords():
	return keywords

func get_width():
	return TOOLTIP_WIDTH

func add_tooltip(pos, title, text, title_image, subtitle = false, play_sfx = false, expanded = false, stylize := true):
	if has_tooltip(title) or TutorialLayer.is_active() or Transition.active:
		return
	var tip = TOOLTIP.instance()
	$Tooltips.add_child(tip)
	tip.setup(title, text, title_image, subtitle, expanded, stylize)
	$Tooltips.position.x = pos.x
	$Tooltips.position.y = pos.y

	yield(tip, "set_up")
	
	call_deferred("fade_tooltip", tip, play_sfx)
	
	for keyword_data in tip.get_keywords_data():
		if keyword_data.type == "tooltip":
			add_tooltip(pos, keyword_data.title, tr(keyword_data.text), keyword_data.title_image, false, true)
		elif keyword_data.type == "status":
			var data = StatusDB.get_from_name(keyword_data.name)
			var tip_text
			if data.use_value_on_tooltip:
				tip_text = tr(data.description+"_GENERIC")
			else:
				tip_text = tr(data.description)
			add_tooltip(pos, data.title_name, tip_text, data.image, false, true)
		elif keyword_data.type == "reagent":
			var tip_data = ReagentManager.get_tooltip(keyword_data.name, false, false, false)
			add_tooltip(pos, tip_data.title, tip_data.text, tip_data.title_image, tip_data.subtitle, true)
			tip_data = ReagentManager.get_substitution_tooltip(keyword_data.name)
			if tip_data:
				add_tooltip(pos, tip_data.title, tip_data.text, tip_data.title_image, null, false, true, false)

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
	var max_width = 0
	for tip in $Tooltips.get_children():
		max_width = tip.get_width() if tip.get_width() > max_width else max_width
		tip.rect_position.y = y
		var h = tip.get_height()
		y += h
		total_height += h
	var screen_w = ProjectSettings.get_setting("display/window/size/width")
	var screen_h = ProjectSettings.get_setting("display/window/size/height")
	$Tooltips.position.y = min($Tooltips.position.y + total_height,
							   screen_h-SCREEN_MARGIN) - total_height
	$Tooltips.position.x = min($Tooltips.position.x + max_width,
							   screen_w-SCREEN_MARGIN) - max_width
