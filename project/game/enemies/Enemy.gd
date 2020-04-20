extends Character
class_name Enemy

signal acted
signal selected

onready var animation = $Sprite/AnimationPlayer
onready var button = $Sprite/Button
onready var health_bar = $HealthBar
onready var intent_texture = $Intent
onready var intent_animation = $Intent/AnimationPlayer
onready var intent_value = $Value
onready var sprite = $Sprite

const SMALL_ENEMY_HEALTHBAR_SIZE = 120
const MEDIUM_ENEMY_HEALTHBAR_SIZE = 180
const BIG_ENEMY_HEALTHBAR_SIZE = 250

const STATUS_BAR_MARGIN = 40
const HEALTH_BAR_MARGIN = 5
const INTENT_MARGIN = 20
const INTENT_W = 50
const INTENT_H = 60

var logic_
var data


func _ready():
	set_button_disabled(true)
	$HealthBar/Shield.hide()

func heal(amount : int):
	.heal(amount)
	update_life()

func take_damage(damage):
	.take_damage(damage)
	update_life()
	update_shield()
	update_status_bar()


func gain_shield(value):
	.gain_shield(value)
	update_shield()

func update_status():
	.update_status()
	update_status_bar()

func update_life():
	health_bar.value = hp
	health_bar.get_node("Label").text = str(hp) + "/" + str(max_hp)

func act():
	var state = logic_.get_current_state()
	data.act(state)
	animation.play("attack")
	yield(animation, "animation_finished")
	animation.play("idle")
	emit_signal("acted")
	logic_.update_state()
	
	update_intent()

func update_shield():
	if shield > 0:
		$HealthBar/Shield.show()
		$HealthBar/Shield/Label.text = str(shield)
	else:
		$HealthBar/Shield.hide()

func update_status_bar():
	#if shield > 0:
	#	$StatusBar.set_status("shield", shield)
	#else:
	#	$StatusBar.remove_status("shield")
	pass


func setup(enemy_logic, new_texture, enemy_data):
	set_logic(enemy_logic)
	set_life(enemy_data)
	set_image(new_texture)

	data = enemy_data #Store enemy data


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


func set_life(enemy_data):
	$HealthBar.max_value = max_hp
	$HealthBar.value = max_hp
	$HealthBar/Label.text = str(max_hp) + "/" + str(max_hp)
	
	if enemy_data.size == "small":
		$HealthBar.rect_size.x = SMALL_ENEMY_HEALTHBAR_SIZE
		$HealthBar/Label.rect_size.x = SMALL_ENEMY_HEALTHBAR_SIZE
	elif enemy_data.size == "medium":
		$HealthBar.rect_size.x = MEDIUM_ENEMY_HEALTHBAR_SIZE
		$HealthBar/Label.rect_size.x = MEDIUM_ENEMY_HEALTHBAR_SIZE
	elif enemy_data.size == "big":
		$HealthBar.rect_size.x = BIG_ENEMY_HEALTHBAR_SIZE
		$HealthBar/Label.rect_size.x = BIG_ENEMY_HEALTHBAR_SIZE
	else:
		push_error("Not a valid enemy size: " + str(enemy_data.enemy_size))
		assert(false)


func set_image(new_texture):
	$Sprite.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	#Update health bar position
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN
	#Update status bar position
	$StatusBar.rect_position.x = w/2 - $StatusBar.rect_size.x/2
	$StatusBar.rect_position.y = $HealthBar.rect_position.y + STATUS_BAR_MARGIN

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
		intent_texture.rect_position.x -= 10
		intent_value.text = str(value)
		intent_value.rect_position.y = - 40
		intent_value.rect_position.x = floor(get_width()/2.0) + 20
									   
	else:
		intent_value.text = ""
		
	
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


func set_button_disabled(disable: bool):
	button.visible = not disable
	button.disabled = disable


func _on_Button_pressed():
	emit_signal("selected", self)
