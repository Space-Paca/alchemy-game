extends Node2D

signal animation_completed

const HEAL_TIME = 1 #TIME to increase health bar when healing
const DAMAGE_TIME = .5 #Time to decrease health bar when taking damage
const ENEMY_FONT = preload("res://game/character/EnemyHealthFont.tres")
const ENEMY_SIZE = {
	"small": 256,
	"medium": 511,
	"big": 963,
}
const PROGRESS_TEXTURE = {
	"small": preload("res://assets/images/ui/Small Enemy Lifebar.png"),
	"medium": preload("res://assets/images/ui/Medium Enemy Lifebar.png"),
	"big": preload("res://assets/images/ui/Huge Enemy Lifebar.png"),
}
const BG_TEXTURE = {
	"small": preload("res://assets/images/ui/Small Enemy Lifebar Holder.png"),
	"medium": preload("res://assets/images/ui/Medium enemy lifebar holder.png"),
	"big": preload("res://assets/images/ui/Huge Enemy Lifebar Holder.png"),
}

onready var label = $Label
onready var shield = $Shield
onready var shield_label = $Shield/Label

func get_width():
	return $Bar.rect_size.x

func get_height():
	return $Bar.rect_size.y

func _ready():
	shield_label.text = str(0)
	shield.modulate = Color(1,1,1,0)

func dummy_rising_number():
	#Add a 0 rising number animation
	AnimationManager.play_rising_number(0, $Center.global_position)
	
	yield(get_tree().create_timer(.4), "timeout")
	emit_signal('animation_completed')

func need_to_update(new_hp, new_shield):
	if (new_hp - $Bar.value == 0) and (new_shield - int(shield_label.text) == 0):
		return false
	return true
	

func update_visuals(new_hp, new_shield):
	#$Tween.
	var updated_life = update_life(new_hp)
	var updated_shield = update_shield(new_shield)
	if updated_life or updated_shield:
		$Tween.start()
		yield($Tween, "tween_all_completed")
		emit_signal('animation_completed')

func update_shield(value):
	var cur_shield = int(shield_label.text)
	var diff = value - cur_shield
	
	#Change shield value
	if value > 0:
		#Add rising number animation
		AnimationManager.play_rising_number(diff, $Shield.rect_global_position)
		
		var dur = .4
		#Check if got shield for the first time
		if cur_shield <= 0:
			$Tween.interpolate_property(shield, "modulate", shield.modulate, Color(1,1,1,1), dur, Tween.TRANS_LINEAR, Tween.EASE_IN)
		
		var prev_scale = shield.rect_scale
		var target_scale = prev_scale * 1.3
		$Tween.interpolate_property(shield, "rect_scale", prev_scale, target_scale, dur/2, Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.interpolate_property(shield, "rect_scale", target_scale, prev_scale, dur/2, Tween.TRANS_QUAD, Tween.EASE_IN, dur/2)
		$Tween.interpolate_method(self, "set_shield_text", cur_shield, value, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
		return true
	
	#Destroy shield
	elif cur_shield > 0:
		#Add rising number animation
		AnimationManager.play_rising_number(diff, $Shield.rect_global_position)
		$Tween.interpolate_method(self, "set_shield_text", cur_shield, value, .4, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.interpolate_property($Shield, "modulate", $Shield.modulate, Color(1,1,1,0), .4, Tween.TRANS_LINEAR, Tween.EASE_IN)
		return true
	else:
		return false

func set_health_text(value):
	label.text = str(floor(value)) + "/" + str($Bar.max_value)

func set_shield_text(value):
	shield_label.text = str(floor(value))

func set_life(hp, max_hp):
	$Bar.max_value = max_hp
	$Bar.value = hp
	$Label.text = str(hp) + "/" + str(max_hp)

func update_life(new_hp):
	var diff = new_hp - $Bar.value
	
	if diff < 0:
		lose_health_effect(abs(diff), new_hp)
		return true
	elif diff > 0:
		gain_health_effect(diff, new_hp)
		return true
	else:
		return false

func get_percent():
	return $Bar.value / float($Bar.max_value)

func set_enemy_type(enemy_size):
	var prog_tex
	var bg_tex
	if PROGRESS_TEXTURE.has(enemy_size):
		prog_tex = PROGRESS_TEXTURE[enemy_size]
		bg_tex = BG_TEXTURE[enemy_size]
	else:
		push_error("Not a valid enemy size: " + str(enemy_size))
		assert(false)
	
	$Bar.texture_progress = prog_tex
	$BarEffect.texture = prog_tex
	$Bar.texture_under = bg_tex
	$Bar.rect_size.x = ENEMY_SIZE[enemy_size]
	$Bar.rect_size.y = 20
	$Label.rect_size = $Bar.rect_size
	$Label.add_font_override("font", ENEMY_FONT)
	$Shield.rect_scale = Vector2(.5,.5)
	$Shield.rect_position.x -= 17
	$Shield.rect_position.y -= 32
	$Center.position = $Bar.rect_size/2

func lose_health_effect(hp_lost, new_hp):
	#Update progress bar with new size
	var old_hp = $Bar.value
	$Bar.value = new_hp
	
	#Set proper scale so effect bar is the same size as progress bar
	$BarEffect.scale.x = $Bar.rect_size.x/$BarEffect.texture.get_width()
	$BarEffect.scale.y = $Bar.rect_size.y/$BarEffect.texture.get_height()
	
	var lost_percent = (hp_lost / float($Bar.max_value))
	
	#Calculate what region of the texture to cut
	var w = lost_percent * $BarEffect.texture.get_width()
	var h = $BarEffect.texture.get_height()
	var x = get_percent() * $BarEffect.texture.get_width()
	var init_rect = Rect2(x, 0, w, h)
	var target_rect = Rect2(x, 0, 0, h)
	$BarEffect.region_rect = init_rect
	
	#Since it is a sprite, position pivot is in the middle
	$BarEffect.position.x = (get_percent() + lost_percent/2)*$Bar.rect_size.x
	$BarEffect.position.y = $Bar.rect_size.y/2
	var target_pos = Vector2(get_percent()*$Bar.rect_size.x, $BarEffect.position.y)
	
	#Start effect, compensating for pivot
	var mod = 8
	var delay = .3
	var dur = DAMAGE_TIME
	$Tween.interpolate_method(self, "set_health_text", old_hp, new_hp, delay, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($BarEffect, "modulate", Color(1,1,1,1), Color(mod,mod,mod,1), delay, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property($BarEffect, "region_rect", init_rect, target_rect, dur, Tween.TRANS_QUAD, Tween.EASE_OUT, delay)
	$Tween.interpolate_property($BarEffect, "position", $BarEffect.position, target_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT, delay)
	
	#Add rising number animation
	AnimationManager.play_rising_number(-hp_lost, $BarEffect.global_position)

func gain_health_effect(hp_gain, new_hp):
	#Update progress bar with new size
	var old_hp = $Bar.value
	
	#Set proper scale so effect bar is the same size as progress bar
	$BarEffect.scale.x = $Bar.rect_size.x/$BarEffect.texture.get_width()
	$BarEffect.scale.y = $Bar.rect_size.y/$BarEffect.texture.get_height()
	
	var gain_percent = (hp_gain / float($Bar.max_value))
	
	#Calculate what region of the texture to cut
	var w = gain_percent * $BarEffect.texture.get_width()
	var h = $BarEffect.texture.get_height()
	var x = get_percent() * $BarEffect.texture.get_width()
	var init_rect = Rect2(x, 0, 0, h)
	var target_rect = Rect2(x, 0, w, h)
	var final_rect = Rect2($BarEffect.texture.get_width(), 0, 0, h)
	$BarEffect.region_rect = init_rect
	
	#Since it is a sprite, position pivot is in the middle
	var init_pos = Vector2(get_percent()*$Bar.rect_size.x, $Bar.rect_size.y/2)
	var target_pos = Vector2((get_percent() + gain_percent/2)*$Bar.rect_size.x, $Bar.rect_size.y/2)
	var final_pos = Vector2((get_percent() + gain_percent)*$Bar.rect_size.x, $Bar.rect_size.y/2)
	$BarEffect.position = init_pos
	
	#Start effect, compensating for pivot
	var mod = 8
	var dur = HEAL_TIME/2.0
	
	#Stretch effect
	$BarEffect.modulate = Color(mod,mod,mod,1)
	$Tween.interpolate_property($BarEffect, "region_rect", init_rect, target_rect, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($BarEffect, "position", init_pos, target_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	#Shrink effect
	$Tween.interpolate_method(self, "set_health_text", old_hp, new_hp, dur, Tween.TRANS_QUAD, Tween.EASE_OUT, dur)
	$Tween.interpolate_property($BarEffect, "region_rect", target_rect, final_rect, dur, Tween.TRANS_QUAD, Tween.EASE_OUT, dur)
	$Tween.interpolate_property($BarEffect, "position", target_pos, final_pos, dur, Tween.TRANS_QUAD, Tween.EASE_OUT, dur)
	#Add rising number animation
	AnimationManager.play_rising_number(hp_gain, $BarEffect.global_position)
	
	#Update progress bar value after first part of effect
	yield(get_tree().create_timer(dur), "timeout")
	$Bar.value = new_hp
