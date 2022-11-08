extends Control

class_name Slot

signal reagent_set
signal reagent_removed

onready var area = $Area2D

var current_reagent = null
var type = null

func get_reagent():
	return current_reagent


func set_reagent(reagent):
	if reagent.slot:
		if reagent.slot == self:
			return
		var emit = false if reagent.slot.type == "grid" and self.type == "grid" else true
		reagent.slot.remove_reagent(emit)
	current_reagent = reagent
	reagent.slot = self
	reagent.target_position = area.global_position
	if reagent.rect_position.distance_to(reagent.target_position) > 0:
		yield(reagent, "reached_target_pos")
	else:
		yield(get_tree(), "idle_frame")
	emit_signal("reagent_set")


func remove_reagent(emit := true):
	current_reagent = null
	if emit:
		emit_signal("reagent_removed")


func get_pos():
	return area.global_position
