extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Restrainer.tscn"
var image = "res://assets/images/enemies/restrainer/idle.png"
var name = "EN_RESTRAINER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 450
var battle_init = false
var size = "big"
var change_phase = null

var states = ["attack1", "attack2", "attack3", "charging", "big_restrain", "medium_restrain"]
var connections = [   
					 
					  ["attack1", "attack2", 4],
					  ["attack1", "attack3", 4],
					  ["attack1", "medium_restrain", 3],
					  ["attack1", "charging", 2],
					  ["attack2", "attack1", 4],
					  ["attack2", "attack3", 4],
					  ["attack2", "medium_restrain", 3],
					  ["attack2", "charging", 2],
					  ["attack3", "medium_restrain", 3],
					  ["attack3", "charging", 3],
					  ["attack3", "attack1", 2],
					  ["attack3", "attack2", 2],
					  ["charging", "big_restrain", 1],
					  ["big_restrain", "attack1", 4],
					  ["big_restrain", "attack2", 4],
					  ["big_restrain", "attack3", 2],
					  ["medium_restrain", "attack1", 4],
					  ["medium_restrain", "attack2", 4],
					  ["medium_restrain", "attack3", 3],
				  ]
var first_state = ["attack1", "attack2"]

var actions = {
	"attack1": [
		{"name": "status", "status_name": "restrain", "value": 6, "target": "player", "positive": false, "animation": ""},
		{"name": "damage", "value": [25, 45], "type": "regular", "animation": "02_atk"}
	],
	"attack2": [
		{"name": "status", "status_name": "restrain", "value": 8, "target": "player", "positive": false, "animation": ""},
		{"name": "damage", "value": [30, 40], "type": "regular", "animation": "02_atk"}
	],
	"attack3": [
		{"name": "damage", "value": 66, "type": "regular", "animation": "02_atk"}
	],
	"charging": [
		{"name": "idle", "sfx": "charge", "animation": ""}
	],
	"big_restrain": [
		{"name": "status", "status_name": "restrain", "value": 16, "target": "player", "positive": false, "animation": ""},
		{"name": "damage", "value": 15, "type": "piercing", "animation": "02_atk"},
		{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true, "animation": ""},
	],
	"medium_restrain": [
		{"name": "status", "status_name": "restrain", "value": 14, "target": "player", "positive": false, "animation": "02_atk"},
		{"name": "status", "status_name": "temp_strength", "value": 20, "target": "self", "positive": true, "animation": ""},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
