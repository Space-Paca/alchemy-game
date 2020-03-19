extends Node2D

var Reagents = null #Setted by parent

func _ready():
	$Center.position = $TextureRect.rect_size/2

func get_center():
	return $Center.global_position
	
func update_counter():
	$Counter.text = str($DiscardedReagents.get_child_count())

func discard(reagent):
	reagent.slot = null
	reagent.can_drag = false
	reagent.target_position = get_center()
	yield(reagent, "reached_target_pos")
	Reagents.remove_child(reagent)
	reagent.visible = false
	$DiscardedReagents.add_child(reagent)
	update_counter()

func return_reagents():
	var all_reagents = []
	for reagent in $DiscardedReagents.get_children():
		$DiscardedReagents.remove_child(reagent)
		all_reagents.append(reagent)
	update_counter()
	return all_reagents
