extends Character
class_name Enemy

signal acted
signal action
signal selected
signal action_resolved
signal resolved
signal updated_visuals_complete

onready var animation = $AnimationPlayer
onready var button = $Button
onready var health_bar = $HealthBar
onready var sprite = $Sprite
onready var tween = $Tween
onready var tooltip = $TooltipCollision
onready var target_particle = $Sprite/CenterPosition/TargetParticle
onready var seasonal_atlases = {
	"halloween": halloween_atlases,
	"eoy_holidays": eoy_holidays_atlases
}

export(Array, Resource) var halloween_atlases
export(Array, Resource) var eoy_holidays_atlases

const INTENT = preload("res://game/enemies/Intent.tscn")

const STATUS_BAR_MARGIN = 40
const HEALTH_BAR_MARGIN = 10
const INTENT_MARGIN = 10
const INTENT_W = 50
const INTENT_H = 60

# Highlight constants
const HL_SPEED = 100
#const HL_MAX_THICKNESS = 15
#const HL_MIN_THICKNESS = 2
const HL_COLOR = Color(0.937255, 1, 0.737255, 0.784314)
const HL_SCALE = Vector2(1, 1)
const HL_HOVER_SCALE = Vector2(1.5, 1.5)

const VARIANT_IDLE_CHANCE = .15

var logic
var data
var difficulty
var enemy_type
var cur_actions
var player
var just_spawned := false
var _playback_speed := 1.0
var already_inited = false
var tooltip_enabled = false

# Quick fix (see _on_AnimationPlayer_animation_finished)
var died := false


func _ready():
	set_button_disabled(true)
	
	if Debug.seasonal_event:
		var atlases = seasonal_atlases[Debug.seasonal_event]
		if atlases.size():
			sprite.animation_state_data_res.skeleton.disconnect("atlas_res_changed",
					sprite.animation_state_data_res, "_on_skeleton_data_changed")
			sprite.animation_state_data_res.skeleton.disconnect("skeleton_data_loaded",
					sprite.animation_state_data_res, "_on_skeleton_data_loaded")
			sprite.animation_state_data_res.skeleton.disconnect("skeleton_json_res_changed",
					sprite.animation_state_data_res, "_on_skeleton_data_changed")
			sprite.animation_state_data_res.skeleton.atlas_res = atlases[randi() % atlases.size()]
	
	#Setup spawn animation
	if data.entry_anim_name:
		animation.play(data.entry_anim_name)
	else:
		scale = Vector2(0,0)
		tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1,1), .2,
			Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.interpolate_property(sprite, "modulate", Color.black, Color.white,
			.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		animation.play(data.idle_anim_name)
	
# warning-ignore:return_value_discarded
	self.connect("stun", self, "stun")
# warning-ignore:return_value_discarded
	self.connect("remove_attack", self, "remove_attack")


func update_life(new_hp, new_shield):
	hp = new_hp
	shield = new_shield
	health_bar.update_visuals(hp, shield)


func heal(amount : int):
	if amount > 0:
		.heal(amount)
		
		#Animation
		AnimationManager.play("heal", get_center_position())
		
		health_bar.update_visuals(hp, shield)
		yield(health_bar, "animation_completed")
		
	emit_signal("resolved")


func die(_reason=false):
	#Audio
	AudioManager.play_enemy_sfx(data.sfx, "dies")
	disable()
	
	#Death animation
	animation.play(data.death_anim_name)
	
	AchievementManager.check_enemy_achievement(data.enemy_type)


func set_grayscale(value: float):
	$Sprite.material.set_shader_param("grayscale", value)


func drain(source: Character, amount: int):
	#Check for weakness status
	if source.get_status("weakness"):
		if not source.is_player() and player.has_artifact("debuff_kit"):
			amount = int(ceil(amount/2.0))
		else:
			amount = int(ceil(2*amount/3.0))
	
	var unblocked_dmg = .take_damage(source, amount, "drain")
	
	if unblocked_dmg > 0:
		source.heal(unblocked_dmg)
	
	if hp > 0 and unblocked_dmg > 0:
		AudioManager.play_enemy_sfx(data.sfx, "hit")
		animation.play(data.dmg_anim_name)
	
	AnimationManager.play("drain", get_center_position())
	
	update_status_bar()
	
	var func_state = health_bar.update_visuals(hp, shield)
	if func_state and func_state.is_valid():
		if hp > 0:
			yield(health_bar, "animation_completed")
		else:
			yield(self, "died")
	
	emit_signal("resolved")


func take_damage(source: Character, damage: int, type: String, retaliate := true):
	var prev_hp = hp
	#Check for weakness status
	if source.get_status("weakness"):
		if not source.is_player() and player.has_artifact("debuff_kit"):
			damage = int(ceil(damage/2.0))
		else:
			damage = int(ceil(2*damage/3.0))
	
	
	var unblocked_dmg = .take_damage(source, damage, type, retaliate)
	if hp > 0 and unblocked_dmg > 0:
		AudioManager.play_enemy_sfx(data.sfx, "hit")
		animation.play(data.dmg_anim_name)
		
	
	if hp <= 0 and get_status("soulbind"):
		remove_status("soulbind")
		var overdamage = abs(prev_hp - unblocked_dmg)
		if overdamage > 0:
			source.take_damage(self, 4*overdamage, "regular", false)

	#Animations
	if type == "regular":
		AnimationManager.play("regular_attack", get_center_position())
	elif type == "piercing":
		AnimationManager.play("piercing_attack", get_center_position())
	elif type == "crushing":
		AnimationManager.play("crushing_attack", get_center_position())
	elif type == "venom":
		AnimationManager.play("venom_attack", get_center_position())
	elif type == "poison":
		AnimationManager.play("poison", get_center_position())
	
	update_status_bar()
	
	var func_state = health_bar.update_visuals(hp, shield)
	if func_state and func_state.is_valid():
		if hp > 0:
			yield(health_bar, "animation_completed")
		else:
			yield(self, "died")
	
	if unblocked_dmg > 0 and source == player:
		if hp > 0 and player.has_artifact("poisoned_dagger"):
			add_status("poison", 2, false)
		if player.has_artifact("shield_damage"):
			player.gain_shield(floor(unblocked_dmg*.5))
		
	
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


#Add status without any effects, when loading hard data
func hard_set_status(status, amount, positive, extra_args):
	.add_status(status, amount, positive, extra_args)
	update_status_bar()


func add_status(status: String, amount, positive: bool, extra_args:= {}):
	var has_weak = get_status("weakness")
	var damage_mod = get_damage_modifiers()
	.add_status(status, amount, positive, extra_args)
	update_status_bar()
	if has_weak != get_status("weakness") or damage_mod != get_damage_modifiers():
		update_intent()
	
	#Animations
	if positive:
		AnimationManager.play("buff", get_center_position())
	else:
		AnimationManager.play("debuff", get_center_position())


func remove_status(status: String):
	.remove_status(status)
	update_status_bar()


func new_turn():
	update_status("start_turn")
	var func_state = (health_bar.update_visuals(hp, shield) as GDScriptFunctionState)
	if func_state and func_state.is_valid():
		yield(health_bar, "animation_completed") 
		emit_signal("updated_visuals_complete")


func update_status(type: String):
	.update_status(type)
	update_status_bar()

func stun():
	cur_actions = [["idle", {}]]
	update_intent()

#Remove all current damage actions from enemy. If there isn't any other action left,
#Stuns enemy
func remove_attack():
	for index in range(cur_actions.size()-1, -1, -1):
		if cur_actions[index][0] == "damage":
			cur_actions.remove(index)
	if cur_actions.size() <= 0:
		stun()

func act():
	run_action()
	yield(self, "action_resolved")
	
	emit_signal("acted")
	
	if hp > 0:
		logic.update_state()
		update_actions()
	

func load_actions(actions_data):
	cur_actions = []
	for action in actions_data:
		cur_actions.append(action)
	update_intent()

func update_actions():
	var state = logic.get_current_state()
	
	cur_actions = []
	for action in data.actions[difficulty][state]:
		var act
		if action.name == "damage":
			var value = get_random_value(action.value) if action.value is Array else action.value
			var amount = action.amount if action.has("amount") else 1
			amount = get_random_value(amount) if amount is Array else amount
			act = ["damage", {"value": value, "type": action.type, "amount": amount, "animation": action.animation}]
		elif action.name == "drain":
			var value = get_random_value(action.value) if action.value is Array else action.value
			var amount = action.amount if action.has("amount") else 1
			act = ["drain", {"value": value, "amount": amount, "animation": action.animation}]
		elif action.name == "self_destruct":
			var value = get_random_value(action.value) if action.value is Array else action.value
			act = ["self_destruct", {"value": value, "animation": action.animation}]
		elif action.name == "shield":
			var value = get_random_value(action.value) if action.value is Array else action.value
			act = ["shield", {"value": value, "animation": action.animation}]
		elif action.name == "heal":
			var value = get_random_value(action.value) if action.value is Array else action.value
			act = ["heal", {"value": value, "target": action.target, "animation": action.animation}]
		elif action.name == "status":
			var value = get_random_value(action.value) if action.value is Array else action.value
			var reduce = action.reduce if action.has("reduce") else false
			var extra_args = action.extra_args if action.has("extra_args") else {}
			act = ["status", {"status": action.status_name, "value": value, \
							  "target": action.target, "positive": action.positive, \
							  "reduce": reduce, "extra_args": extra_args, "animation": action.animation}]
		elif action.name == "spawn":
			act = ["spawn", {"enemy": action.enemy, "minion": action.has("minion"), "animation": action.animation}]
		elif action.name == "add_reagent":
			act = ["add_reagent", {"type": action.type, "value": action.value, "animation": action.animation}]
		elif action.name == "idle":
			var sfx = {"sfx": action.sfx} if action.has("sfx") else {}
			act = ["idle", sfx]
		else:
			push_error("Not a valid action:" + str(action.name))
			assert(false)
		cur_actions.append(act)
	
	#DEBUG: Override enemy action
#	cur_actions = [["damage", {"value": 1, "type": "piercing", "amount": 1, "animation": ""}]]
	
	update_intent()


func run_action():
	emit_signal("action", self, cur_actions)


#Returns a random value given an interval array [min, max]
func get_random_value(interval : Array):
	randomize()
	return randi()%(interval[1]-interval[0]+1) + interval[0]


func play_animation(name: String):
	if name and name != "":
		animation.play(name)


func action_resolved():
	emit_signal("action_resolved")


func update_status_bar():
	$StatusBar.clean_removed_status(status_list)
	var status_type = status_list.keys();
	for type in status_type:
		var status = status_list[type]
		$StatusBar.set_status(type, status.amount, status.positive)


func get_center_position():
	return $Sprite/CenterPosition.global_position


func setup(enemy_logic, new_texture, enemy_data, _player, _difficulty):
	set_logic(enemy_logic)
	set_life(enemy_data)
	set_image(new_texture)
	data = enemy_data #Store enemy data
	difficulty = _difficulty
	player = _player

func set_logic(enemy_logic):
	logic = load("res://game/enemies/EnemyLogic.gd").new()
	
	for state in enemy_logic.states:
		logic.add_state(state)
	for link in enemy_logic.connections:
		logic.add_connection(link[0], link[1], link[2])
	
	#Get random first state
	randomize()
	enemy_logic.first_state.shuffle()
	logic.set_state(enemy_logic.first_state.front())


func set_life(enemy_data):
	$HealthBar.set_life(max_hp, max_hp)
	$HealthBar.set_enemy_type(enemy_data.size)


#Called when player dies
func disable():
	$StatusBar.disable()
	for intent in $Intents.get_children():
		intent.disable()


#Called when player dies
func enable():
	$StatusBar.enable()
	for intent in $Intents.get_children():
		intent.enable()


func set_image(new_texture):
	var margin = 40
	var w = new_texture.get_width()
	var h = new_texture.get_height() - margin
	
	#Update texture
#	$Sprite.texture = new_texture

	#Sprite Position
#	$Sprite.position.x = 0
#	$Sprite.position.y = 0

	#Update health bar position
	$HealthBar.position.x = -$HealthBar.get_width()*$HealthBar.scale.x/2
#	$HealthBar.position.y = $Sprite.position.y + h + HEALTH_BAR_MARGIN - h/2
	$HealthBar.position.y = h/2 + HEALTH_BAR_MARGIN
	
	#Update status bar position
	$StatusBar.rect_position.x = $HealthBar.position.x
	$StatusBar.rect_position.y = $HealthBar.position.y + STATUS_BAR_MARGIN
	$StatusBar.setup($HealthBar.get_width()*$HealthBar.scale.x)
	
	#Update intents position
	$Intents.position.y = $Sprite.position.y -INTENT_MARGIN - INTENT_H - h/2
	$Intents.position.y = -INTENT_MARGIN - INTENT_H - h/2
	
	# Button
	$Button.rect_position = Vector2(-w/2, -h/2)
	$Button.rect_size = Vector2(w, h)
	
	# Tooltip
	$TooltipCollision.position = Vector2(0, 0)
	$TooltipCollision.set_collision_shape(Vector2(w,h))


func get_actions_data():
	return cur_actions.duplicate(true)


#Removes first intent (the one in the left)
func remove_intent():
	if $Intents.get_child_count() > 0:
		var intent = $Intents.get_child(0)
		intent.vanish()
		yield(intent, "vanished")
		if $Intents.get_children().has(intent):
			$Intents.remove_child(intent)
			update_intents_position()


func clear_intents():
	for intent in $Intents.get_children():
		$Intents.remove_child(intent)


func add_intent(action, texture, value, multiplier):
	var intent = INTENT.instance()
	$Intents.add_child(intent)
	intent.setup(self, player, action, texture, value, multiplier)
	yield(intent, "set_up")
	update_intents_position()


func update_intents_position():
	var int_n = $Intents.get_child_count()
	var separation = 2
	var w = separation * (int_n - 1)
	for intent in $Intents.get_children():
		w += intent.get_width()
	var x = $Sprite.position.x - w/2
	for intent in $Intents.get_children():
		tween.interpolate_property(intent, "position", intent.position, Vector2(x, 0), .2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		x += intent.get_width() + separation
	tween.start()


func set_pos(target_pos):
	randomize()
	var tw = $MoveTween
	var speed = rand_range(1800, 2200)
	var dur = (position - target_pos).length()/speed
	tw.remove_all()
	tw.interpolate_property(self, "position", position, target_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tw.start()


func update_intents_by_data(intent_data):
	clear_intents()
	for d in intent_data:
		var intent = IntentManager.create_intent_data(d.action)
		add_intent(d.action, intent.texture, d.value, d.multiplier)


func update_intent():
	clear_intents()
	for action in cur_actions:
		var intent = IntentManager.create_intent_data(action)
		if intent.has("value"):
			var value = int(intent.value)
			var name = action[0]
			if name == "damage" or name == "drain":
				value = max(0, value + get_damage_modifiers())
				if get_status("weakness"):
					if player and player.has_artifact("debuff_kit"):
						value = int(ceil(value/2.0))
					else:
						value = int(ceil(2*value/3.0))
			if intent.has("multiplier"):
				add_intent(intent.action, intent.image, value, intent.multiplier)
			else:
				add_intent(intent.action, intent.image, value, null)
		else:
			add_intent(intent.action, intent.image, null, null)


func get_width():
	return sprite.texture.get_width()


func get_height():
	return sprite.texture.get_height()


func set_button_disabled(disable: bool):
	button.visible = not disable
	button.disabled = disable
	
	var color := HL_COLOR
	color.a = 0 if disable else 1
	target_particle.modulate = color


func get_tooltip():
	var tip = {"title": data.name, "text": "", \
				   "title_image": false, "subtitle": "ENEMY"}

	return tip


func disable_tooltips():
	remove_tooltips()
	$TooltipCollision.disable()


func enable_tooltips():
	tooltip.enable()


func remove_tooltips():
	if tooltip_enabled:
		tooltip_enabled = false
		TooltipLayer.clean_tooltips()


func _on_Button_pressed():
	tween.stop(target_particle)
	target_particle.scale = HL_SCALE
	emit_signal("selected", self)


func _on_Button_mouse_entered():
	var duration = (1 - target_particle.modulate.a) / HL_SPEED
	tween.stop(target_particle)
	tween.interpolate_property(target_particle, "scale", null, HL_HOVER_SCALE,
			duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func _on_Button_mouse_exited():
	var duration = target_particle.modulate.a / HL_SPEED
	tween.stop(target_particle)
	tween.interpolate_property(target_particle, "scale", null, HL_SCALE,
			duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func _on_TooltipCollision_disable_tooltip():
	if tooltip_enabled:
		remove_tooltips()


func _on_TooltipCollision_enable_tooltip():
	tooltip_enabled = true
	var tip = get_tooltip()
	TooltipLayer.add_tooltip(tooltip.get_position(), tip.title, \
							 tip.text, tip.title_image, tip.subtitle, true)


func _on_Sprite_animation_complete(_animation_state, track_entry, _event):
	var anim_name = track_entry.get_animation().get_anim_name()
	if anim_name == data.death_anim_name:
		if not died:
			emit_signal("died", self)
			died = true
	elif hp == 0:
		#Weird condition race where another animation was finished at the same time enemy is dying
		animation.play(data.death_anim_name)
	elif anim_name == data.idle_anim_name:
		var variant_idle = data.get_variant_idle()
		if variant_idle and randf() < VARIANT_IDLE_CHANCE:
			animation.play(variant_idle)
	elif data.should_idle(anim_name):
		animation.play(data.idle_anim_name)


func _on_AnimationPlayer_animation_finished(anim_name):
	# Quick fix to speed up baby poison death
	if anim_name == data.death_anim_name:
		if not died:
			emit_signal("died", self)
			died = true
	elif hp == 0:
		#Weird condition race where another animation was finished at the same time enemy is dying
		animation.play(data.death_anim_name)
