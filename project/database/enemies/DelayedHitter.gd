extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/DelayedHitter.tscn"
var image = "res://assets/images/enemies/delayed hitter/idle.png"
var name = "EN_DELAYED_HITTER"
var sfx = "virulyn-prowler"
var use_idle_sfx = false
var hp = 25
var battle_init = false
var size = "small"
var change_phase = null

var states = ["attack", "preparing1", "preparing2", "preparing3"]
var connections = [
					  ["preparing1", "preparing2", 1],
					  ["preparing2", "preparing3", 1],
					  ["preparing3", "attack", 1],
					  ["attack", "attack", 1],
				  ]
var first_state = ["preparing1"]

var actions = {
	"preparing1": [
		{"name": "idle", "sfx": "charge", "animation": ""}
	],
	"preparing2": [
		{"name": "idle", "sfx": "charge", "animation": ""}
	],
	"preparing3": [
		{"name": "idle", "sfx": "charge", "animation": ""}
	],
	"attack": [
		{"name": "damage", "value": [16, 18], "type": "regular", "animation": "atk"},
	],
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
