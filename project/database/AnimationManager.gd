extends Node

const RISING = preload("res://game/character/RisingNumber.tscn")

const SHIELD = preload("res://game/vfx/shield/Shield.tscn")

onready var ANIM = {
	"area_attack": $Animations/AreaAttack,
	"regular_attack": $Animations/RegularAttack,
	"piercing_attack": $Animations/PiercingAttack,
	"crushing_attack": $Animations/CrushingAttack,
	"venom_attack": $Animations/Poison,
	"poison": $Animations/Poison,
	"heal": $Animations/Heal,
	"buff": $Animations/Buff,
	"debuff": $Animations/Debuff,
	"drain": $Animations/Drain,
	"spawn": $Animations/Summon
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
	if name == "shield":
		animation = SHIELD.instance()
	else:
		animation = ANIM[name].duplicate()
	
	$AnimationLayer.add_child(animation)
	animation.position = pos
	animation.show()
	
	yield(animation.get_node("AnimationPlayer"), "animation_finished")
	
	animation.queue_free()
