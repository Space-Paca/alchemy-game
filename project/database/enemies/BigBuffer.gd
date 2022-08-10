extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BigBuffer.tscn"
var image = "res://assets/images/enemies/buffing big enemy/idle.png"
var name = "EN_BIG_BUFFER"
var sfx = "morhk"
var use_idle_sfx = false
var hp = 80
var battle_init = false
var size = "medium"
var change_phase = null

var states = ["temp_buff", "perm_buff", "attack"]
var connections = [["temp_buff", "attack", 3],
				   ["temp_buff", "temp_buff", 1],
				   ["attack", "perm_buff", 1],
				   ["perm_buff", "temp_buff", 1],
				   ["perm_buff", "attack", 3],
				   ["perm_buff", "temp_buff", 1],
						 ]
var first_state = ["temp_buff"]

var actions = {
	"temp_buff": [
		{"name": "status", "status_name": "temp_strength", "value": 11, "target": "self", "positive": true, "animation": "idle"}
	],
	"perm_buff": [
		{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true, "animation": "idle"}
	],
	"attack": [
		{"name": "damage", "value": [4,6], "type": "regular", "animation": "atk"},
	]
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
#	variant_idles = [""]
