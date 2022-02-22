extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Poison.tscn"
var image = "res://assets/images/enemies/poison elite/idle.png"
var name = "EN_POISUN"
var sfx = "fat_monster"
var use_idle_sfx = true
var hp = 80
var battle_init = false
var size = "big"
var change_phase = null

var states = ["poison", "defend-poison", "attack-poison", "poison-attack"]
var connections = [
					  ["poison", "defend-poison", 5],
					  ["poison", "attack-poison", 3],
					  ["poison", "poison-attack", 3],
					  ["defend-poison", "poison", 1],
					  ["attack-poison", "poison", 1],
					  ["poison-attack", "poison", 1],
				  ]
var first_state = ["poison"]

var actions = {
	"poison": [
		{"name": "damage", "value": [8, 15], "type": "venom", "animation": "atk"},
	],
	"attack-poison": [
		{"name": "damage", "value": [3,8], "type": "regular", "animation": "atk"},
		{"name": "damage", "value": [5,6], "type": "venom", "animation": "atk"},
	],
	"poison-attack": [
		{"name": "damage", "value": [5,6], "type": "venom", "animation": "atk"},
		{"name": "damage", "value": [10,12], "type": "regular", "animation": "atk"},
	],
	"defend-poison": [
		{"name": "shield", "value": [13,15], "animation": ""},
		{"name": "damage", "value": [5, 10], "type": "venom", "animation": "atk"},
	]
}


func _init():
	idle_anim_name = "idle"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
