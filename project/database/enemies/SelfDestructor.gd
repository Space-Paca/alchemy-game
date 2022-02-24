extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/SelfDestructor.tscn"
var image = "res://assets/images/enemies/self destructor/idle.png"
var name = "EN_SELF_DESTRUCTOR"
var sfx = "toxic_slime_minion"
var use_idle_sfx = false
var hp = 5
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init","attack", "self_destruct"]
var connections = [
					  ["init", "attack", 1],
					  ["attack", "self_destruct", 1],
					  ["self_destruct", "self_destruct", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 30, "animation": ""},
		{"name": "status", "status_name": "tough", "value": 1, "target": "self", "positive": true, "animation": ""}
	],
	"attack": [
		{"name": "damage", "value": [4,5], "amount": 2, "type": "regular", "animation": "02_atk"}
	],
	"self_destruct": [
		{"name": "self_destruct", "value": 30, "animation": "02_atk"}
	]
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
