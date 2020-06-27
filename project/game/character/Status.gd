extends HBoxContainer

const STATUS_IMAGES = {
					   "dodge": "res://assets/images/status/dodge.png",
					   "evasion": "res://assets/images/status/dodge.png",
					   "perm_strength": "res://assets/images/status/perm_strength.png",
					   "temp_strength": "res://assets/images/status/temp_strength.png",
					   "poison": "res://assets/images/status/poison.png",
					   "guard_up": "res://assets/images/status/random_status.png",
					   "retaliate": "res://assets/images/status/random_status.png",
					  }
const STATUS_TOOLTIPS = {
					   "dodge": {
						"title": "Dodge",
						"text": "This character will avoid the next attack. Last until end of turn.",
						"title_image": STATUS_IMAGES.dodge},
					   "evasion": {
						"title": "Evasion",
						"text": "This character has 50% chance of avoiding the next attack. Last until it triggers or end of turn.",
						"title_image": STATUS_IMAGES.evasion},
					   "retaliate": {
						"title": "Retaliate",
						"text": "This character returns 1 regular damage per stack each time it is attacked. Lasts until end of turn",
						"title_image": STATUS_IMAGES.retaliate},
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
						"text": "This character is dealt 1 poison damage per stack. Decreases every turn",
						"title_image": STATUS_IMAGES.poison},
					   "guard_up": {
						"title": "Guard Up",
						"text": "Whenever this characters is attacked, if it wasn't shielded, gains shield",
						"title_image": STATUS_IMAGES.guard_up},
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
