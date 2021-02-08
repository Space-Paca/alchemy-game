extends Node

const RISING = preload("res://game/character/RisingNumber.tscn")

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
	"spawn": $Animations/Summon,
	"shield": $Animations/Shield,
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
	
	if name == "shield":
		return
	
	var animation = ANIM[name].duplicate()
	animation.position = pos
	animation.show()
	
	$AnimationLayer.add_child(animation)
	yield(animation.get_node("AnimationPlayer"), "animation_finished")
	
	animation.queue_free()
