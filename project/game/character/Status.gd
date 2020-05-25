extends HBoxContainer

const STATUS_IMAGES = {
					   "dodge": "res://assets/images/status/dodge.png",
					   "perm_strength": "res://assets/images/status/perm_strength.png",
					   "temp_strength": "res://assets/images/status/temp_strength.png",
					   "poison": "res://assets/images/status/Debuff Poison.png",
					  }
const STATUS_TOOLTIPS = {
					   "dodge": {
						"title": "Dodge",
						"text": "This character will avoid the next attack. Last until end of turn.",
						"title_image": STATUS_IMAGES.dodge},
					   "perm_strength": {
						"title": "Permanent Strength",
						"text": "Permanently increases this character attack damage",
						"title_image": STATUS_IMAGES.perm_strength},
					   "temp_strength": {
						"title": "Temporary Strength",
						"text": "Increases the damage of this character next attack",
						"title_image": STATUS_IMAGES.temp_strength},
					   "poison": {
						"title": "Poison",
						"text": "This character is taking poison damage each turn",
						"title_image": STATUS_IMAGES.poison},
					  }

var type : String
var positive : bool

func init(_type: String, value, _positive: bool):
	type = _type
	positive = _positive
	
	assert(STATUS_IMAGES.has(type))
	$Image.texture = load(STATUS_IMAGES[type])
	if value:
		set_value(value)
	else:
		set_value("")

func set_value(value):
	$Value.text = str(value)

func get_self_tooltip():
	if STATUS_TOOLTIPS.has(type):
		return STATUS_TOOLTIPS[type]
	else:
		push_error("Not a valid type of status: " + str(type))
		assert(false)
