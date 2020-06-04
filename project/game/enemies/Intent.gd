extends Node2D

signal vanished
signal setted_up

func _ready():
	modulate = Color(1,1,1,0)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), .3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
func setup(texture, value, multiplier):
	$Image.texture = texture
	
	#Add value
	
	if value:
		$Value.text = str(value)
	else:
		$Value.text = ""
	#Add multiplier
	if multiplier:
		$X.text = "x"
		$Multiplier.text = str(multiplier)
	else:
		$X.text = ""
		$Multiplier.text = ""
	
	yield(get_tree(), "idle_frame")
	update_position()
	emit_signal("setted_up")

func update_position():
	var margin = 1
	$Value.rect_position.x = $Image.rect_size.x + margin
	margin = -8
	$X.rect_position.x = $Value.rect_position.x + $Value.rect_size.x + margin
	$X.rect_position.y = $Value.rect_position.y + $Value.rect_size.y - $X.rect_size.y
	margin = 10
	$Multiplier.rect_position.x = $X.rect_position.x + $X.rect_size.x + margin
	$Multiplier.rect_position.y = $Value.rect_position.y + $Value.rect_size.y - $Multiplier.rect_size.y

func get_width():
	var w = $Image.rect_size.x
	if $Value.text != "":
		w += $Value.rect_size.x
	if $Multiplier.text != "":
		w += $X.rect_size.x + $Multiplier.rect_size.x
	return w

func vanish():
	var dur = .2
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), dur/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "scale", Vector2(1,1), Vector2(0,1), dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "position", position, Vector2(position.x + get_width()/2,0), dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("vanished")
