extends HBoxContainer

const STATUS_IMAGES = {
					   "dodge": "res://assets/images/status/random_status.png",
					   "perm_strength": "res://assets/images/status/perm_strength.png",
					   "temp_strength": "res://assets/images/status/temp_strength.png",
					  }

var type : String
var positive : bool

func init(_type, value, _positive):
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
