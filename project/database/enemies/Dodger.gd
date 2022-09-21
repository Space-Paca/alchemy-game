extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Dodger.tscn"
var image = "res://assets/images/enemies/dodge enemy/idle.png"
var name = "EN_DODGER"
var sfx = "nimble"
var use_idle_sfx = false
var hp = 21
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = ["init", "dodge", "attack", "big_attack"]
var connections = [	      ["init", "big_attack", 1],
						  ["big_attack", "dodge", 1],
						  ["big_attack", "attack", 5],
						  ["dodge", "big_attack", 1],
						  ["attack", "attack", 2],
						  ["attack", "dodge", 1],
						  ["attack", "big_attack", 7],
				 ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true, "animation": "dodge"}
	],
	"dodge": [
		{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true, "animation": "dodge2"}
	],
	"attack": [
		{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true, "animation": "dodge"},
		{"name": "damage", "value": [7, 9], "type": "regular", "animation": "02_atk"},
	],
	"big_attack": [
		{"name": "damage", "value": [9, 13], "type": "regular", "animation": "02_atk"},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
