extends Node

const RISING = preload("res://game/character/RisingNumber.tscn")

onready var ANIM = {
	"regular_attack": preload("res://game/vfx/regular/RegularAttack.tscn"),
	"piercing_attack": preload("res://game/vfx/piercing/PiercingAttack.tscn"),
	"crushing_attack": preload("res://game/vfx/crushing/CrushingAttack.tscn"),
	"venom_attack": preload("res://game/vfx/venom/VenomAttack.tscn"),
	"poison": preload("res://game/vfx/poison/Poison.tscn"),
	"heal": preload("res://game/vfx/heal/Heal.tscn"),
	"buff": preload("res://game/vfx/buff/Buff.tscn"),
	"debuff": preload("res://game/vfx/debuff/Debuff.tscn"),
	"drain": preload("res://game/vfx/drain/Drain.tscn"),
	"spawn": preload("res://game/vfx/spawn/Summon.tscn"),
	"shield": preload("res://game/vfx/shield/Shield.tscn")
}

func play_rising_number(value, pos: Vector2):
	var rising_number = RISING.instance()
	$RisingNumberLayer.add_child(rising_number)
	rising_number.position = pos
	rising_number.setup(value)

func play(name: String, pos: Vector2):
	if not ANIM.has(name):
		push_error("Not a valid animation:" + str(name))
		assert(false)
	
	var animation = ANIM[name].instance()
	
	animation.position = pos
	$AnimationLayer.add_child(animation)
	
	yield(animation.get_node("AnimationPlayer"), "animation_finished")
	
	animation.queue_free()
