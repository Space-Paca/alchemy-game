extends Character

signal acted

onready var animation = $Sprite/AnimationPlayer
onready var health_bar = $HealthBar
onready var intent_texture = $Intent
onready var intent_animation = $Intent/AnimationPlayer
onready var intent_value = $Value
onready var sprite = $Sprite

const HEALTH_BAR_MARGIN = 10
const INTENT_MARGIN = 10
const INTENT_W = 60
const INTENT_H = 70

var logic_
var data


func act():
	var state = logic_.get_current_state()
	data.act(state)
	animation.play("attack")
	yield(animation, "animation_finished")
	animation.play("idle")
	emit_signal("acted")
	logic_.update_state()
	
	update_intent()


func setup(enemy_logic, new_texture, enemy_data):
	set_logic(enemy_logic)
	set_max_hp()
	set_image(new_texture)

	data = enemy_data


func set_logic(enemy_logic):
	logic_ = load("res://game/enemies/EnemyLogic.gd").new()
	
	for state in enemy_logic.states:
		logic_.add_state(state)
	for link in enemy_logic.connections:
		logic_.add_connection(link[0], link[1], link[2])
	
	#Get random first state
	randomize()
	enemy_logic.first_state.shuffle()
	logic_.set_state(enemy_logic.first_state.front())


func set_max_hp():
	$HealthBar.max_value = max_hp
	$HealthBar.value = max_hp


func set_image(new_texture):
	$Sprite.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN


func set_intent(texture, value):	
	intent_texture.texture = texture
	var tw = texture.get_width()
	var th = texture.get_height()
	
	#Fix Pivot offset
	intent_texture.rect_pivot_offset = Vector2(tw/2.0, th/2.0)
	
	#Fix position
	intent_texture.rect_position.x = floor(get_width()/2.0) - tw/2.0
	intent_texture.rect_position.y = floor(-th/2.0) - INTENT_MARGIN
	
	#Fix scale
	intent_texture.rect_scale = Vector2(INTENT_W/float(tw), INTENT_H/float(th))
	
	#Add value
	if value:
		intent_texture.rect_position.x -= 30
		intent_value.text = str(value)
	else:
		intent_value.text = ""
		intent_value.rect_position.y = - 50
		intent_value.rect_position.x = intent_texture.rect_position.x + \
									   INTENT_W * intent_texture.rect_scale.x
	
	#Random position for idle animation
	randomize()
	intent_animation.seek(rand_range(0,1.5))


func update_intent():
	var state = logic_.get_current_state()
	var intent_data = data.get_intent_data(state)
	set_intent(intent_data.image, intent_data.value)


func get_width():
	return sprite.texture.get_width()


func get_height():
	return sprite.texture.get_height()
