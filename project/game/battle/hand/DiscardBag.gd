extends Node2D

signal reagent_discarded(reagent)

onready var center = $Center
onready var counter = $Counter
onready var discarded_reagents = $DiscardedReagents
onready var texture_rect = $TextureRect

var tooltips_enabled := false

func _ready():
	center.position = texture_rect.rect_size/2


func get_center():
	return center.global_position

func get_width():
	return texture_rect.rect_size.x

func get_height():
	return texture_rect.rect_size.y

func update_counter():
	counter.text = str(discarded_reagents.get_child_count())

func is_empty():
	return discarded_reagents.get_child_count() == 0

func discard(reagent):
	AudioManager.play_sfx("discard_reagent")
	reagent.shrink()
	reagent.slot = null
	reagent.can_drag = false
	reagent.target_position = get_center()
	yield(reagent, "reached_target_pos")
	
	emit_signal("reagent_discarded", reagent)
	reagent.visible = false
	discarded_reagents.add_child(reagent)
	update_counter()


func return_reagents():
	var all_reagents = []
	for reagent in discarded_reagents.get_children():
		discarded_reagents.remove_child(reagent)
		all_reagents.append(reagent)
	update_counter()
	return all_reagents

func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_TooltipCollision_enable_tooltip():
	tooltips_enabled = true
	TooltipLayer.add_tooltip($TooltipPosition.global_position, "Discard Bag", "You've got SADNESS", true)

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
