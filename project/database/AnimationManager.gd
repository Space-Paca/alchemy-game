extends Node

const RISING = preload("res://game/character/RisingNumber.tscn")

onready var ANIM = {
	"area_attack": preload("res://game/vfx/area-attack/AreaAttack.tscn"),
	"regular_attack": preload("res://game/vfx/regular-attack/RegularAttack.tscn"),
	"piercing_attack": $Animations/PiercingAttack,
	"crushing_attack": $Animations/CrushingAttack,
	"venom_attack": $Animations/Poison,
	"poison": $Animations/Poison,
	"heal": $Animations/Heal,
	"buff": $Animations/Buff,
	"debuff": $Animations/Debuff,
	"drain": $Animations/Drain,
	"spawn": $Animations/Summon,
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
	
	var animation
	if name in ["shield", "regular_attack"]:
		animation = ANIM[name].instance()
	else:
		animation = ANIM[name].duplicate()
		animation.show()
	
	animation.position = pos
	$AnimationLayer.add_child(animation)
	
	yield(animation.get_node("AnimationPlayer"), "animation_finished")
	
	animation.queue_free()
