extends Character
class_name Enemy

signal acted
signal selected
signal action_resolved
signal animation_finished
signal resolved

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
var just_spawned := false
var tooltip_position := Vector2()
var tooltips_enabled := false
var block_tooltips := false
var _playback_speed := 1.0


func _ready():
	set_button_disabled(true)
	
	#Setup idle animation
	animation.play("idle")
	randomize()
	animation.seek(rand_range(0.0, 2.0))
	randomize()
	_playback_speed = rand_range(1.0, 1.3)
	animation.playback_speed = _playback_speed
	
	#Setup spawn animation
	scale = Vector2(0,0)
	$Tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1,1), .2, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()

func heal(amount : int):
	if amount > 0:
		.heal(amount)
		
		#Animation
		AnimationManager.play("heal", get_center_position())
		
		health_bar.update_visuals(hp, shield)
		yield(health_bar, "animation_completed")
		
	emit_signal("resolved")

func die():
	#Audio
	AudioManager.play_enemy_dies_sfx(data.sfx)
	
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
	var pre_shield = shield
	var unblocked_dmg = .take_damage(source, damage, type)
	if hp > 0 and unblocked_dmg > 0:
		AudioManager.play_enemy_hit_sfx(data.sfx)
	
	
	#Animations
	if type == "regular":
		AnimationManager.play("regular_attack", get_center_position())
	elif type == "piercing":
		AnimationManager.play("piercing_attack", get_center_position())
	elif type == "crushing":
		AnimationManager.play("crushing_attack", get_center_position())
	elif type == "poison":
		AnimationManager.play("poison", get_center_position())
	
	update_status_bar()
	
	if unblocked_dmg > 0 or abs(pre_shield - shield) > 0:
		health_bar.update_visuals(hp, shield)
		if hp > 0:
			yield(health_bar, "animation_completed")
		else:
			yield(self, "died")
	
	emit_signal("resolved")

func gain_shield(value):
	if value > 0:
		.gain_shield(value)
		
		#Animation
		AnimationManager.play("shield", get_center_position())
		
		health_bar.update_visuals(hp, shield)
		yield(health_bar, "animation_completed")
	
	emit_signal("resolved")

func reduce_status(status: String, amount: int):
	.reduce_status(status, amount)
	update_status_bar()

func add_status(status: String, amount: int, positive: bool):
	.add_status(status, amount, positive)
	update_status_bar()
	
	#Animations
	if positive:
		AnimationManager.play("buff", get_center_position())
	else:
		AnimationManager.play("debuff", get_center_position())

func remove_status(status: String):
	.remove_status(status)
	update_status_bar()

func new_turn():
	update_status()
	health_bar.update_visuals(hp, shield)

func update_status():
	.update_status()
	update_status_bar()

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

func update_status_bar():
	$StatusBar.clean_removed_status(status_list)
	var status_type = status_list.keys();
	for type in status_type:
		var status = status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)

func get_center_position():
	return $Sprite.rect_global_position + $Sprite.texture.get_width()*$Sprite.rect_scale/2

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
	$HealthBar.set_life(max_hp, max_hp)
	$HealthBar.set_enemy_type(enemy_data.size)

#Called when player dies
func disable():
	block_tooltips = true
	disable_tooltips()

func update_tooltip_position():
	var margin = 10
	$TooltipPosition.position = Vector2($Sprite.rect_position.x + $Sprite.texture.get_width() + margin, \
							   			$Sprite.rect_position.y - INTENT_MARGIN - INTENT_H)

func set_image(new_texture):
	$Sprite.texture = new_texture
	var w = new_texture.get_width()
	var h = new_texture.get_height()
	#Sprite Position
	$Sprite.rect_position.x = -w/2
	$Sprite.rect_position.y = -h/2
	#Update pivot
	$Sprite.rect_pivot_offset.x = w/2
	$Sprite.rect_pivot_offset.y = h/2
	#Update health bar position
	$HealthBar.position.x = -$HealthBar.get_width()*$HealthBar.scale.x/2
	$HealthBar.position.y = $Sprite.rect_position.y + h + HEALTH_BAR_MARGIN
	#Update status bar position
	$StatusBar.rect_position.x = $HealthBar.position.x
	$StatusBar.rect_position.y = $HealthBar.position.y + STATUS_BAR_MARGIN
	#Update tooltip collision
	var t_w = max(w, $HealthBar.get_width()*$HealthBar.scale.x)
	var t_h = INTENT_H +  INTENT_MARGIN + h + \
			  HEALTH_BAR_MARGIN + $HealthBar.get_height()*$HealthBar.scale.y + \
			  STATUS_BAR_MARGIN + $StatusBar.rect_size.y
	$TooltipCollision.position = Vector2(min($HealthBar.position.x, $Sprite.rect_position.x) + t_w/2, \
										 -INTENT_H - INTENT_MARGIN + t_h/2)
	$TooltipCollision.set_collision_shape(Vector2(t_w, t_h))
	#Update intents position
	$Intents.position.y = $Sprite.rect_position.y -INTENT_MARGIN - INTENT_H

#Removes first intent (the one in the left)
func remove_intent():
	if $Intents.get_child_count() > 0:
		var intent = $Intents.get_child(0)
		intent.vanish()
		yield(intent, "vanished")
		$Intents.remove_child(intent)
		update_intents_position()

func clear_intents():
	for intent in $Intents.get_children():
		$Intents.remove_child(intent)

func add_intent(texture, value, multiplier):
	var intent = INTENT.instance()
	$Intents.add_child(intent)
	intent.setup(texture, value, multiplier)
	yield(intent, "setted_up")
	update_intents_position()

func update_intents_position():
	var int_n = $Intents.get_child_count()
	var separation = 2
	var w = separation * (int_n - 1)
	for intent in $Intents.get_children():
		w += intent.get_width()
	var x = $Sprite.rect_position.x - w
	for intent in $Intents.get_children():
		$Tween.interpolate_property(intent, "position", intent.position, Vector2(x, 0), .2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		x += intent.get_width() + separation
	$Tween.start()

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
			if intent.has("multiplier"):
				add_intent(intent.image, intent.value, intent.multiplier)
			else:
				add_intent(intent.image, intent.value, null)
		else:
			add_intent(intent.image, null, null)

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
