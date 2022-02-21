extends Reference
class_name EnemyData

var anim_precedes_idle : Array


func should_idle(anim_name: String) -> bool:
	return anim_precedes_idle.has(anim_name)
