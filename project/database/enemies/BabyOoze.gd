extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BabyPoison.tscn"
var image = "res://assets/images/enemies/small poison enemy/idle.png"
var name = "EN_BABY_OOZE"
var sfx = "oozeling"
var use_idle_sfx = false
var hp = 6
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init", "poison", "defend-poison", "medium-poison"]
var connections = [
					  ["init", "poison", 1],
					  ["poison", "defend-poison", 5],
					  ["poison", "medium-poison", 3],
					  ["defend-poison", "medium-poison", 1],
					  ["medium-poison", "defend-poison", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 6, "animation": "stand"}
	],
	"poison": [
		{"name": "damage", "value": [5,7], "type": "venom", "animation": "atk"}
	],
	"medium-poison": [
		{"name": "damage", "value": [3,6], "type": "venom", "animation": "atk"}
		
	],
	"defend-poison": [
		{"name": "shield", "value": [7,9], "animation": ""},
		{"name": "damage", "value": [2,4], "type": "venom", "animation": "atk"}
	]
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
#	entry_anim_name = "enter"
	variant_idles = ["stand2", "stand3", "stand4"]
