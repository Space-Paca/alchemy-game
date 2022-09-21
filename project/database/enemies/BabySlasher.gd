extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BabySlasher.tscn"
var image = "res://assets/images/enemies/small piercing/idle.png"
var name = "EN_BABY_SLASHER"
var sfx = "needler-spawn"
var use_idle_sfx = false
var hp = 5
var battle_init = false
var size = "small"
var change_phase = null
var unique_bgm = null

var states = ["attack"]
var connections = [
					  ["attack", "attack", 1],
				  ]
var first_state = ["attack"]

var actions = {
	"attack": [
		{"name": "damage", "value": [2,3], "type": "piercing", "animation": "atk"}
	]
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
