extends HBoxContainer

const STATUS_IMAGES = {
					   "shield": "res://assets/images/status/shield_status.png",
					  }

var type

func init(_type, value):
	type = _type
	
	assert(STATUS_IMAGES.has(type))
	$Image.texture = load(STATUS_IMAGES[type])
	if value:
		set_value(value)
	else:
		set_value("")

func set_value(value):
	$Value.text = str(value)
