extends Character
class_name Enemy

signal acted
signal selected
signal action_resolved
signal animation_finished

onready var animation = $Sprite/AnimationPlayer
onready var button = $Sprite/Button
onready var health_bar = $HealthBar
onready var sprite = $Sprite

const INTENT = preload("res://game/enemies/Intent.tscn")

const SMALL_ENEMY_HEALTHBAR_SIZE = 120
const MEDIUM_ENEMY_HEALTHBAR_SIZE = 180
const BIG_ENEMY_HEALTHBAR_SIZE = 250

const STATUS_BAR_MARGIN = 40
const HEALTH_BAR_MARGIN = 5
const INTENT_MARGIN = 5
const INTENT_W = 50
const INTENT_H = 60

var logic_
var data
var tooltip_position := Vector2()
var tooltips_enabled := false
var block_tooltips := false


func _ready():
	set_button_disabled(true)
	$HealthBar/Shield.hide()
	$Intents.rect_position.y = -INTENT_MARGIN - INTENT_H

func heal(amount : int):
	.heal(amount)
	update_life()

func die():
	.die()
	
	AudioManager.play_enemy_dies_sfx(data.sfx)

	disable_tooltips()


func take_damage(source: Character, damage: int, type: String):
	var unblocked_dmg = .take_damage(source, damage, type)
	if hp > 0 and unblocked_dmg > 0:
		AudioManager.play_enemy_hit_sfx(data.sfx)
		
	update_life()
	update_shield()
	update_status_bar()

func gain_shield(value):
	.gain_shield(value)
	update_shield()

func add_status(status: String, amount: int, positive: bool):
	.add_status(status, amount, positive)
	update_status_bar()

func remove_status(status: String):
	.remove_status(status)
	update_status_bar()

func new_turn():
	update_status()
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
	yield(self, "action_resolved")
	emit_signal("acted")
	logic_.update_state()
	
	update_intent()

func play_animation(name):
	animation.play(name)
	yield(animation, "animation_finished")
	emit_signal("animation_finished")
	animation.play("idle")

func action_resolved():
	emit_signal("action_resolved")

func update_shield():
	if shield > 0:
		$HealthBar/Shield.show()
		$HealthBar/Shield/Label.text = str(shield)
	else:
		$HealthBar/Shield.hide()

func update_status_bar():
	$StatusBar.clean_removed_status(status_list)
	var status_type = status_list.keys();
	for type in status_type:
		var status = status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)

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

#Called when player dies
func disable():
	block_tooltips = true
	disable_tooltips()

func set_image(new_texture):
	$Sprite.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	#Update intent conteiner
	$Intents.rect_size.x = w
	$Intents.rect_size.y = INTENT_H
	#Update health bar position
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN
	#Update status bar position
	$StatusBar.rect_position.x = $HealthBar.rect_position.x
	$StatusBar.rect_position.y = $HealthBar.rect_position.y + STATUS_BAR_MARGIN
	#Update tooltip collision
	var t_w = w
	var t_h = INTENT_H +  INTENT_MARGIN + h + \
			  HEALTH_BAR_MARGIN + $HealthBar.rect_size.y + \
			  STATUS_BAR_MARGIN + $StatusBar.rect_size.y
	$TooltipCollision.position = Vector2(t_w/2, - INTENT_H - INTENT_MARGIN + t_h/2)
	$TooltipCollision.set_collision_shape(Vector2(t_w, t_h))

#Removes first intent (the one in the left)
func remove_intent():
	if $Intents.get_child_count() > 0:
		var intent = $Intents.get_child(0)
		intent.vanish()
		yield(intent, "vanished")
		$Intents.remove_child(intent)

func clear_intents():
	for intent in $Intents.get_children():
		$Intents.remove_child(intent)

func add_intent(texture, value):
	var intent = INTENT.instance()
	$Intents.add_child(intent)
	
	intent.setup(texture, value)

func set_pos(pos):
	position = pos
	tooltip_position = Vector2(pos.x - TooltipLayer.get_width(), \
							   pos.y - INTENT_MARGIN - INTENT_H)

func update_intent():
	clear_intents()
	var state = logic_.get_current_state()
	var intent_data = data.get_intent_data(state)
	for intent in intent_data:
		add_intent(intent.image, intent.value)

func get_width():
	return sprite.texture.get_width()

func get_height():
	return sprite.texture.get_height()

func get_tooltips():
	var tooltips = []
	#Get intent tooltip
	var state = logic_.get_current_state()
	for intent_tooltip in data.get_intent_tooltips(state):
		tooltips.append(intent_tooltip)
	#Get status tooltips
	for tooltip in $StatusBar.get_status_tooltips():
		tooltips.append(tooltip)
	return tooltips

func set_button_disabled(disable: bool):
	button.visible = not disable
	button.disabled = disable

func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_Button_pressed():
	emit_signal("selected", self)

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	var play_sfx = true
	tooltips_enabled = true
	for tooltip in get_tooltips():
		TooltipLayer.add_tooltip(tooltip_position, tooltip.title, tooltip.text, play_sfx)
		play_sfx = false

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
