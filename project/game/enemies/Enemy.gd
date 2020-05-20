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

const STATUS_BAR_MARGIN = 40
const HEALTH_BAR_MARGIN = 10
const INTENT_MARGIN = 5
const INTENT_W = 50
const INTENT_H = 60

var logic_
var data
var tooltip_position := Vector2()
var tooltips_enabled := false
var block_tooltips := false
var _playback_speed := 1.0
var idle_player : AudioStreamPlayer


func _ready():
	set_button_disabled(true)
	$Intents.rect_position.y = -INTENT_MARGIN - INTENT_H
	
	#Settup idle animation
	animation.play("idle")
	randomize()
	animation.seek(rand_range(0.0, 2.0))
	randomize()
	_playback_speed = rand_range(1.0, 1.3)
	animation.playback_speed = _playback_speed

func heal(amount : int):
	.heal(amount)
	update_life()

func die():
	#Audio
	AudioManager.play_enemy_dies_sfx(data.sfx)
	if idle_player:
		idle_player.stop()
	
	disable_tooltips()
	
	#Death animation
	$Tween.interpolate_method(self, "set_grayscale", 0, 1, .2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	emit_signal("died", self)

func set_grayscale(value: float):
	$Sprite.material.set_shader_param("grayscale", value)

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
	health_bar.update_life(hp)

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
	randomize()
	animation.seek(rand_range(0.0, 2.0))
	animation.playback_speed = _playback_speed


func action_resolved():
	emit_signal("action_resolved")

func update_shield():
	health_bar.update_shield(shield)

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
	set_audio(enemy_data)
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
	$HealthBar.set_life(max_hp, max_hp)
	$HealthBar.set_enemy_type(enemy_data.size)

func set_audio(enemy_data):
	if enemy_data.use_idle_sfx:
		idle_player = AudioManager.get_enemy_idle_sfx(enemy_data.sfx)
		add_child(idle_player)

#Called when player dies
func disable():
	block_tooltips = true
	disable_tooltips()

func update_tooltip_position():
	var margin = 5
	$TooltipPosition.position = Vector2(min($Sprite.rect_position.x, $HealthBar.rect_position.x) - TooltipLayer.get_width() - margin, \
							   			$Sprite.rect_position.y - INTENT_MARGIN - INTENT_H)

func set_image(new_texture):
	$Sprite.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	#Update pivot
	$Sprite.rect_pivot_offset.x = w/2
	$Sprite.rect_pivot_offset.y = h/2
	#Update intent conteiner
	$Intents.rect_size.x = w
	$Intents.rect_size.y = INTENT_H
	#Update health bar position
	$HealthBar.rect_position.x = w/2 - $HealthBar.rect_size.x*$HealthBar.rect_scale.x/2
	$HealthBar.rect_position.y = h + HEALTH_BAR_MARGIN
	#Update status bar position
	$StatusBar.rect_position.x = $HealthBar.rect_position.x
	$StatusBar.rect_position.y = $HealthBar.rect_position.y + STATUS_BAR_MARGIN
	#Update tooltip collision
	var t_w = w
	var t_h = INTENT_H +  INTENT_MARGIN + h + \
			  HEALTH_BAR_MARGIN + $HealthBar.rect_size.y*$HealthBar.rect_scale.y + \
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

func set_pos(target_pos):
	randomize()
	var speed = rand_range(2000, 2500)
	var dur = (position - target_pos).length()/speed
	$Tween.interpolate_property(self, "position", position, target_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

func update_intent():
	clear_intents()
	var state = logic_.get_current_state()
	var intent_data = data.get_intent_data(state)
	for intent in intent_data:
		if intent.has("value"):
			add_intent(intent.image, intent.value)
		else:
			add_intent(intent.image, null)

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
		update_tooltip_position()
		TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
								 tooltip.text, tooltip.title_image, play_sfx)
		play_sfx = false

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
