extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Revenger.tscn"
var image = "res://assets/images/enemies/revenger/idle.png"
var name = "EN_REVENGER"
var sfx = "revenger"
var use_idle_sfx = false
var hp = 35
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = ["init", "attack", "defend"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "defend", 1],
					  ["attack", "defend", 1],
					  ["attack", "attack", 2],
					  ["defend", "attack", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "revenge", "value": 15, "target": "self", "positive": true, "animation": ""}
	],
	"attack": [
		{"name": "damage", "value": [12, 15], "type": "regular", "animation": "02_atk"}
	],
	"defend": [
		{"name": "shield", "value": [10, 15], "animation": "03_dmg"},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
