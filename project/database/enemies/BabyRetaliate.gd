extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BabyRetaliate.tscn"
var image = "res://assets/images/enemies/baby retaliate/idle.png"
var name = "EN_BABY_RETALIATE"
var sfx = "wolftopus"
var use_idle_sfx = false
var hp = 42
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init", "attack"]
var connections = [
					  ["init", "attack", 1],
					  ["attack", "attack", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "retaliate", "value": 5, "target": "self", "positive": true, "animation": "03_dmg"},
	],
	"attack": [
		{"name": "status", "status_name": "retaliate", "value": 5, "target": "self", "positive": true, "animation": "03_dmg"},
		{"name": "damage", "value": [9,18], "type": "regular", "animation": "02_atk"}
	]
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
