extends HBoxContainer

signal deleted
signal value_updated
signal status_ready

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
	$Value.text = ""
	$Image.texture = load(STATUS_IMAGES[type])
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	if value:
		update_value(value)
		yield(self, "value_updated")
	else:
		update_value("")
		yield($Tween, "tween_completed")
	

	emit_signal("status_ready")

func delete():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), .5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("deleted")

func update_value(value):
	if $Value.text == str(value):
		return
	$Value.text = str(value)
	$Value.rect_pivot_offset = $Value.rect_size
	var dur = .3
	var scale = 1.5
	$Tween.interpolate_property($Value, "rect_scale", Vector2(1,1), Vector2(scale, scale), dur/2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property($Value, "rect_scale", Vector2(scale,scale), Vector2(1, 1), dur/2, Tween.TRANS_QUAD, Tween.EASE_OUT, dur/2)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("value_updated")
	
func get_self_tooltip():
	if STATUS_TOOLTIPS.has(type):
		return STATUS_TOOLTIPS[type]
	else:
		push_error("Not a valid type of status: " + str(type))
		assert(false)
