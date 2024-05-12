extends Node2D

const SPEED = 2
const HEALTHY_COLOR = Color(0.0, 0.9, 0.94)
const MIDLIFE_COLOR = Color(0.9, 0.9, 0.0)
const DYING_COLOR = Color(0.96, 0.13, 0.13)
const ANIMATIONS = {
	"alchemist": {
		"idle": "idle",
		"weak_damage": "dmg1_weak",
		"average_damage": "dmg2_middle",
		"strong_damage": "dmg3_strong",
		"attack": ["atk"],
		"blink": ["blink1", "blink2"],
	},
	"steadfast": {
		"idle": "idle",
		"weak_damage": "dmg1",
		"average_damage": "dmg1",
		"strong_damage": "dmg2",
		"attack": ["atk1", "atk2", "atk3"],
		"blink": ["idle"]
	},
	"toxicologist": {
		"idle": "idle",
		"weak_damage": "dmg1",
		"average_damage": "dmg1",
		"strong_damage": "dmg2",
		"attack": ["atk1", "atk2"],
		"blink": ["blink"]
	},
}

onready var bg = $BG
onready var static_portraits = $Static
onready var animated_portraits = $Animated
onready var portraits = {
	"alchemist": $Static/AlcSprite,
	"steadfast": $Static/SteSprite,
	"toxicologist": $Static/ToxSprite,
}
onready var animation_players = {
	"alchemist": $Animated/AlcSpineSprite/AnimationPlayer,
	"steadfast": $Animated/SteSpineSprite/AnimationPlayer,
	"toxicologist": $Animated/ToxSpineSprite/AnimationPlayer,
}
onready var spine_sprites = {
	"alchemist": $Animated/AlcSpineSprite,
	"steadfast": $Animated/SteSpineSprite,
	"toxicologist": $Animated/ToxSpineSprite,
}

var state = "normal"
var player_class = "alchemist"
var anim
var spine_sprite
var image


func set_player(player):
	var debug_portrait = Debug.get_portrait()
	if debug_portrait:
		image.texture = debug_portrait
	else:
		player_class = player.player_class.name
		anim = animation_players[player_class]
		spine_sprite = spine_sprites[player_class]
		image = portraits[player_class]
		for portrait in portraits.values():
			portrait.visible = portrait == image
		for sprite in spine_sprites.values():
			sprite.visible = sprite == spine_sprite


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
	
	animated_portraits.show()
	static_portraits.hide()


func set_state(new_state):
	state = new_state


func get_random_animation(anim_array: Array):
	return anim_array[randi() % anim_array.size()]


func get_animation_name(action: String):
	match action:
		"blink":
			return get_random_animation(ANIMATIONS[player_class]["blink"])
		"attack":
			return get_random_animation(ANIMATIONS[player_class]["attack"])
		var other_action:
			return ANIMATIONS[player_class][other_action]


func play_animation(action: String):
	if Debug.custom_portrait:
		return
	
	anim.play(get_animation_name(action))


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "idle" and randf() < .3:
		play_animation("blink")
	else:
		play_animation("idle")
