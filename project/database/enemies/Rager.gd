extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Rager.tscn"
var image = "res://assets/images/enemies/rager/idle.png"
var name = "EN_RAGER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 100
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack1", "attack2", "attack3"]
var connections = [
					  ["init", "attack1", 1],
					  ["attack1", "attack2", 1],
					  ["attack2", "attack3", 1],
					  ["attack3", "attack1", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "enrage", "value": 8, "target": "self", "positive": true, "animation": "02_atk"}
	],
	"attack1": [
		{"name": "damage", "value": [4, 7], "type": "regular", "animation": "02_atk"}
	],
	"attack2": [
		{"name": "damage", "value": [4, 7], "type": "regular", "animation": "02_atk"}
	],
	"attack3": [
		{"name": "damage", "value": 1, "amount": 3, "type": "regular", "animation": "02_atk"}
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
