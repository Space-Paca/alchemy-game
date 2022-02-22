extends Reference
class_name EnemyData

var variant_idles : Array
var idle_anim_name : String
var death_anim_name : String
var dmg_anim_name : String
var entry_anim_name : String


func should_idle(anim_name: String) -> bool:
	return anim_name != idle_anim_name and anim_name != death_anim_name


func get_variant_idle():
	if not variant_idles.size():
		return null
	return variant_idles[randi()%variant_idles.size()]
