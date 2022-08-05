extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/MediumDivider.tscn"
var image = "res://assets/images/enemies/medium divider/idle.png"
var name = "EN_MEDIUM_DIVIDER"
var sfx = "divider"
var use_idle_sfx = false
var hp = 65
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "defend", "poison", "first", "second"]
var connections = [
					  ["init", "first", 1],
					  ["first", "second", 1],
					  ["second", "poison", 1],
					  ["attack", "poison", 1],
					  ["defend", "poison", 1],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": [18, 20], "animation": ""},
		{"name": "status", "status_name": "splitting", "value": 1, "target": "self", "positive": true, "extra_args": {"enemy": "small_divider"}, "animation": ""}
	],
	"attack": [
		{"name": "damage", "value": [15, 25], "type": "regular", "animation": "02_atk"}
	],
	"defend": [
		{"name": "shield", "value": [10, 18], "animation": ""},
		{"name": "damage", "value": [10, 15], "type": "regular", "animation": "02_atk"}
	],
	"poison": [
		{"name": "damage", "value": [10, 15], "type": "venom", "animation": "02_atk"},
	],
	"first": [
		{"name": "shield", "value": [18, 20], "animation": ""},
	],
	"second": [
		{"name": "damage", "value": [8,10], "type": "venom", "animation": "02_atk"},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
