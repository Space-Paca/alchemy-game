extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BabyCarapa.tscn"
var image = "res://assets/images/enemies/small regular enemy/idle.png"
var name = "EN_BABY_CARAPA"
var sfx = "wolftopus"
var use_idle_sfx = false
var hp = 15
var battle_init = false
var size = "small"
var change_phase = null


var states = ["attack"]
var connections = [
					  ["attack", "attack", 1],
				  ]
var first_state = ["attack"]

var actions = {
	"attack": [
		{"name": "damage", "value": [5,7], "type": "regular", "animation": "atk"}
	]
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
	entry_anim_name = "enter"
	variant_idles = ["idle", "idle2"]
