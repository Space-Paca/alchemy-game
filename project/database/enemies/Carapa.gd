extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Carapa.tscn"
var image = "res://assets/images/enemies/regular enemy/idle.png"
var name = "EN_CARAPA"
var sfx = "turtle_spider"
var use_idle_sfx = false
var hp = 45
var battle_init = false
var size = "medium"
var change_phase = null

var states = ["attack", "defend"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "attack", 5],
					  ["defend", "attack", 1],
				  ]
var first_state = ["attack", "defend"]

var actions = {
	"attack": [
		{"name": "damage", "value": [10, 15], "type": "regular", "animation": "atk2"}
	],
	"defend": [
		{"name": "shield", "value": [4, 6], "animation": "defense"},
		{"name": "damage", "value": [5, 7], "type": "regular", "animation": "atk"}
	],
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	entry_anim_name = "enter"
	variant_idles = ["idle", "idle2"]
