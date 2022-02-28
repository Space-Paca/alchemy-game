extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Curser.tscn"
var image = "res://assets/images/enemies/curser/idle.png"
var name = "EN_CURSER"
var sfx = "curser"
var use_idle_sfx = false
var hp = 100
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "debuff"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "debuff", 1],
					  ["attack", "attack", 2],
					  ["attack", "debuff", 1],
					  ["debuff", "attack", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "curse", "value": 2, "target": "player", "positive": false, "animation": "02_atk"}
	],
	"attack": [
		{"name": "damage", "value": [10, 20], "type": "regular", "animation": "02_atk"}
	],
	"debuff": [
		{"name": "shield", "value": [5, 18], "animation": ""},
		{"name": "status", "status_name": "weakness", "value": 1, "target": "player", "positive": false, "animation": "02_atk"}
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
