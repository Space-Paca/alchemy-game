extends Node2D

const SPEED = 2
const HEALTHY_COLOR = Color(0.0, 0.9, 0.94)
const MIDLIFE_COLOR = Color(0.9, 0.9, 0.0)
const DYING_COLOR = Color(0.96, 0.13, 0.13)
const ATLANTES = {
	"alchemist": preload("res://assets/spine/player_portrait/alchemist.atlas"),
	"toxicologist": preload("res://assets/spine/player_portrait/toxicologist.atlas"),
	"steadfast": preload("res://assets/spine/player_portrait/steadfast.atlas"),
}

onready var bg = $BG
onready var image = $Sprite
onready var anim = $AnimationPlayer
onready var spine_sprite = $SpineSprite

var state = "normal"


func set_player(player):
	var debug_portrait = Debug.get_portrait()
	if debug_portrait:
		image.texture = debug_portrait
	else:
		image.texture = player.player_class.portrait
	spine_sprite.animation_state_data_res.skeleton.disconnect("atlas_res_changed",
			spine_sprite.animation_state_data_res, "_on_skeleton_data_changed")
	spine_sprite.animation_state_data_res.skeleton.disconnect("skeleton_data_loaded",
			spine_sprite.animation_state_data_res, "_on_skeleton_data_loaded")
	spine_sprite.animation_state_data_res.skeleton.disconnect("skeleton_json_res_changed",
			spine_sprite.animation_state_data_res, "_on_skeleton_data_changed")
	spine_sprite.animation_state_data_res.skeleton.atlas_res = ATLANTES[player.player_class.name]



func _process(delta):
	var color
	if state == "normal":
		color = HEALTHY_COLOR
	elif state == "danger":
		color = MIDLIFE_COLOR
	elif state == "extreme-danger":
		color = DYING_COLOR
	
	bg.modulate.r += (color.r - bg.modulate.r)*min(SPEED*delta, 1)
	bg.modulate.g += (color.g - bg.modulate.g)*min(SPEED*delta, 1)
	bg.modulate.b += (color.b - bg.modulate.b)*min(SPEED*delta, 1)


func update_visuals(hp, max_hp):
	var percent = hp / float(max_hp)
	if percent > .5:
		set_state("normal")
	elif percent > .2:
		set_state("danger")
	elif percent > .0:
		set_state("extreme-danger")


func set_battle_mode():
	if Debug.custom_portrait:
		return
	
	spine_sprite.show()
	image.hide()
	anim.play("idle")


func set_state(new_state):
	state = new_state


func play_animation(name: String):
	anim.play(name)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "idle":
		anim.play("idle")
	else:
		var rand = randf()
		if rand < .2:
			anim.play("blink 1")
		elif rand < .4:
			anim.play("blink 2")
		else:
			anim.play("idle")
