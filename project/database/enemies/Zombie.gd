extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Zombie.tscn"
var image = "res://assets/images/enemies/zombie/idle.png"
var name = "EN_ZOMBIE"
var sfx = "zombie"
var use_idle_sfx = false
var hp = 60
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = ["init", "drain", "attack"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "drain", 1],
					  ["attack", "attack", 2],
					  ["attack", "drain", 1],
					  ["drain", "attack", 3],
					  ["drain", "drain", 1],
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "poison_immunity", "value": 1, "target": "self", "positive": true, "animation": ""}
	],
	"drain": [
		{"name": "drain", "value": [15, 20], "animation": "02_Atk"}
	],
	"attack": [
		{"name": "damage", "value": [20,30], "type": "regular", "animation": "02_Atk"}
	],
}


func _init():
	idle_anim_name = "01_Idle"
	death_anim_name = "04_Death"
	dmg_anim_name = "03_Dmg"
