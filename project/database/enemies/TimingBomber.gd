extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/TimingBomber.tscn"
var image = "res://assets/images/enemies/timing bomber/idle.png"
var name = "EN_TIMING_BOMBER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 202
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "bomb-time", "attack", "defend", "big-attack"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "defend", 1],
					  ["attack", "bomb-time", 1],
					  ["attack", "defend", 1],
					  ["big-attack", "bomb-time", 1],
					  ["big-attack", "defend", 1],
					  ["defend", "attack", 4],
					  ["defend", "big-attack", 3],
					  ["defend", "bomb-time", 4],
					  ["bomb-time", "attack", 4],
					  ["bomb-time", "big-attack", 3],
					  ["bomb-time", "defend", 4]
					
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false, "animation": "taunt2"}
	],
	"bomb-time": [
		{"name": "status", "status_name": "time_bomb", "value": 8, "target": "player", "positive": false, "animation": "taunt2"}
	],
	"attack": [
		{"name": "status", "status_name": "time_bomb", "value": 3, "target": "player", "positive": false, "animation": "taunt2"},
		{"name": "damage", "value": [15,17], "type": "regular", "animation": "atk"},
	],
	"big-attack": [
		{"name": "status", "status_name": "time_bomb", "value": 2, "target": "player", "positive": false, "animation": "taunt2"},
		{"name": "damage", "value": [19,25], "type": "regular", "animation": "atk"},
	],
	"defend": [
		{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false, "animation": "taunt2"},
		{"name": "shield", "value": [14,15], "animation": "atk"}
	],
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death2"
	dmg_anim_name = "dmg2"
	entry_anim_name = "enter"
	variant_idles = ["idle", "idle2"]
