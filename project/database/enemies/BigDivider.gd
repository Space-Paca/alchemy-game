extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BigDivider.tscn"
var image = "res://assets/images/enemies/big divider/idle.png"
var name = "EN_BIG_DIVIDER"
var sfx = "divider"
var use_idle_sfx = false
var hp = 80
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "defend", "poison"]
var connections = [
					  ["init", "poison", 1],
					  ["attack", "poison", 1],
					  ["defend", "poison", 1],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "splitting", "value": 1, "target": "self", "positive": true, "extra_args": {"enemy": "medium_divider"}, "animation": ""}
	],
	"attack": [
		{"name": "damage", "value": [20, 30], "type": "regular", "animation": "02_atk"}
	],
	"defend": [
		{"name": "shield", "value": [15, 20], "animation": ""},
		{"name": "damage", "value": [10, 20], "type": "regular", "animation": "02_atk"}
	],
	"poison": [
		{"name": "damage", "value": [15, 25], "type": "venom", "animation": "02_atk"},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
