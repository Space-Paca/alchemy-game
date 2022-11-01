extends Node2D

signal vanished
signal set_up

var block_tooltips := false
var tooltips_enabled := false
var enemy = null
var player = null
var action = null

func _ready():
	modulate = Color(1,1,1,0)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), .3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func setup(_enemy, _player, _action, texture, value, multiplier):
	player = _player
	enemy = _enemy
	action = _action
	$Image.texture = texture
	
	#Add value
	if typeof(value) == TYPE_INT:
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
	emit_signal("set_up")

func update_position():
	var margin = 2
	var padding = 3
	$Value.rect_position.x = $Image.rect_size.x + margin
	margin = -18
	$X.rect_position.x = $Value.rect_position.x + $Value.rect_size.x + margin
	$X.rect_position.y = $Value.rect_position.y + $Value.rect_size.y - $X.rect_size.y - padding
	margin = 7
	$Multiplier.rect_position.x = $X.rect_position.x + $X.rect_size.x + margin
	$Multiplier.rect_position.y = $Value.rect_position.y + $Value.rect_size.y - $Multiplier.rect_size.y - padding
	
	#Update tooltip info
	var w
	if $Multiplier.text == "":
		if $Value.text == "":
			w = $Image.rect_position.x + $Image.rect_size.x
		else:
			w = $Value.rect_position.x + $Value.rect_size.x
	else:
		w = $Multiplier.rect_position.x + $Multiplier.rect_size.x
	var h = $Image.rect_size.y
	$TooltipCollision.position.x = w/2
	$TooltipCollision.position.y = h/2
	$TooltipCollision.set_collision_shape(Vector2(w,h))
	$TooltipPosition.position = Vector2(w + 5, -10)

func get_width():
	var w = $Image.rect_size.x
	if $Value.text != "":
		w += $Value.rect_size.x
	if $Multiplier.text != "":
		w += $X.rect_size.x + $Multiplier.rect_size.x
	return w

func vanish():
	disable()
	var dur = .2
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), dur/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "scale", Vector2(1,1), Vector2(0,1), dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "position", position, Vector2(position.x + get_width()/2,0), dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("vanished")

func get_self_tooltip():
	return IntentManager.get_intent_tooltip(action, enemy, player)

func disable():
	block_tooltips = true
	disable_tooltips()

func enable():
	block_tooltips = false

func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = get_self_tooltip()
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, null, true)
