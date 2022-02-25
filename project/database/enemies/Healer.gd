extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Healer.tscn"
var image = "res://assets/images/enemies/healer/idle.png"
var name = "EN_HEALER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 170
var battle_init = true
var size = "small"
var change_phase = null

var states = ["attack", "defend", "heal", "init"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "defend", 1],  
					  ["heal", "attack", 1],
					  ["heal", "defend", 1],
					  ["attack", "attack", 1],
					  ["attack", "defend", 1],
					  ["attack", "heal", 2],
					  ["defend", "attack", 1],
					  ["defend", "defend", 1],
					  ["defend", "heal", 2],
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 50, "animation": ""},
	],
	"attack": [
		{"name": "damage", "value": 20, "type": "regular", "animation": ""},
		{"name": "heal", "value": [10,20], "target": "all_enemies", "animation": ""},
	],
	"defend": [
		{"name": "shield", "value": [10, 50], "animation": ""},
		{"name": "heal", "value": [10,20], "target": "all_enemies", "animation": ""},
	],
	"heal": [
		{"name": "heal", "value": [20,30], "target": "all_enemies", "animation": ""},
		{"name": "status", "status_name": "perm_strength", "value": 8, "target": "self", "positive": true, "animation": ""},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
