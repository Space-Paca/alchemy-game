extends Character

signal acted

const HEALTH_BAR_MARGIN = 10
const INTENT_MARGIN = 5
const INTENT_W = 60
const INTENT_H = 70

const INTENTS = {"attack": preload("res://assets/images/enemies/intents/attack.png"),
				 "defend": preload("res://assets/images/enemies/intents/defense.png"),
				 "random": preload("res://assets/images/enemies/intents/random.png"),
				}

var logic_

func act():
	var state = logic_.get_current_state()
	print("Going to "+state+"!")
	$AnimationPlayer.play("attack")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	emit_signal("acted")
	logic_.update_state()

	update_intent()

func setup(enemy_logic, new_texture):
	set_logic(enemy_logic)
	set_max_hp()
	set_image(new_texture)

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

func set_intent(intent):
	assert(INTENTS.has(intent))
	var texture = INTENTS[intent]
	$Intent.texture = texture
	
	#Fix scale	
	var tw = texture.get_width()
	var th = texture.get_height()
	$Intent.rect_scale = Vector2(INTENT_W/float(tw), INTENT_H/float(th))
	
	#Fix position
	$Intent.rect_position.x = get_width()/2 - INTENT_W/2
	$Intent.rect_position.y = -INTENT_H - INTENT_MARGIN	

func update_intent():
	var state = logic_.get_current_state()
	set_intent(state)

func get_width():
	return $Sprite.texture.get_width()

func get_height():
	return $Sprite.texture.get_height()
