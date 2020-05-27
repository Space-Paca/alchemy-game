extends Node

onready var ANIM = {
	"area_attack": $Animations/AreaAttack,
	"regular_attack": $Animations/RegularAttack,
	"piercing_attack": $Animations/PiercingAttack,
	"crushing_attack": $Animations/CrushingAttack,
	"poison": $Animations/Poison,
	"heal": $Animations/Heal,
	"buff": $Animations/Buff,
	"debuff": $Animations/Debuff,
	"summon": $Animations/Summon,
	"shield": $Animations/Shield,
}


func play(name: String, pos: Vector2):
	if not ANIM.has(name):
		push_error("Not a valid animation:" + str(name))
		assert(false)
	
	var animation = ANIM[name].duplicate()
	animation.position = pos
	animation.show()
	
	$AnimationLayer.add_child(animation)
	yield(animation.get_node("AnimationPlayer"), "animation_finished")
	
	animation.queue_free()
