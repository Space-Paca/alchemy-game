extends TextureRect
class_name Slot

signal reagent_set

onready var area = $Area2D

var current_reagent = null


func get_reagent():
	return current_reagent


func set_reagent(reagent):
	if reagent.slot:
		reagent.slot.remove_reagent()
	current_reagent = reagent
	reagent.slot = self
	reagent.target_position = area.global_position
	yield(reagent, "reached_target_pos")
	emit_signal("reagent_set")


func remove_reagent():
	current_reagent = null


func get_pos():
	return area.global_position
