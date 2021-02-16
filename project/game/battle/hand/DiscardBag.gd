extends Node2D

const TOOLTIP_LINE_HEIGHT = 34

signal reagent_discarded(reagent)
signal reagent_exploded

onready var center = $Center
onready var counter = $TextureRect/Counter
onready var discarded_reagents = $DiscardedReagents
onready var texture_rect = $TextureRect

var player = null #Setted by parent
var tooltips_enabled := false
var block_tooltips := false

func _ready():
	center.position = texture_rect.rect_size/2
	update_counter()

func disable():
	disable_tooltips()
	block_tooltips = true

func enable():
	block_tooltips = false

func copy_bag(other_bag):
	for c in discarded_reagents.get_children():
		discarded_reagents.remove_child(c)
	
	for reagent in other_bag.discarded_reagents.get_children():
		var reagent_object = ReagentManager.create_object(reagent.type)
		add_reagent(reagent_object, false)
	
	update_counter()

func get_center():
	return center.global_position

func get_width():
	return texture_rect.rect_size.x

func get_height():
	return texture_rect.rect_size.y

func update_counter():
	counter.text = str(discarded_reagents.get_child_count())


func get_reagent_names() -> Array:
	var names := []
	for reagent in discarded_reagents.get_children():
		names.append(reagent.type)
	return names


func is_empty():
	return discarded_reagents.get_child_count() == 0

func discard(reagent):
	if reagent.unstable:
		reagent.toggle_unstable()
		reagent.explode()
		yield(reagent, "exploded")
		emit_signal("reagent_exploded", player, 10, "regular", false)
	reagent.slot = null
	reagent.can_drag = false
	reagent.target_position = get_center()
	reagent.speed_mod = .5
	reagent.effect_mod = .4
	reagent.shrink()
	yield(reagent, "reached_target_pos")
	
	reagent.speed_mod = 1
	reagent.effect_mod = 1
	emit_signal("reagent_discarded", reagent)
	add_reagent(reagent)

func add_reagent(reagent, should_update_counter: = true):
	reagent.disable_tooltips()
	reagent.disable_dragging()
	reagent.visible = false
	discarded_reagents.add_child(reagent)
	if should_update_counter:
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

func get_tooltip():
	var tooltip = {}
	tooltip.title = "Discard Bag"
	tooltip.text = ""
	var reagent_types = {}
	for reagent in $DiscardedReagents.get_children():
		if not reagent_types.has(reagent.type):
			reagent_types[reagent.type] = 0
		reagent_types[reagent.type] += 1
	var keys = reagent_types.keys()
	keys.sort()
	
	#Get appropriate position for tooltip
	tooltip.pos = $TooltipPosition.global_position - Vector2(0,keys.size()*TOOLTIP_LINE_HEIGHT)
	
	if keys.size() <= 0:
		tooltip.text += "- empty - "
	
	for key in keys:
		var path = ReagentDB.get_from_name(key).image.get_path()
		#For some reason \n just reases other images, so using gambiara to properly change lines
		tooltip.text += "[img=40x40]"+path+"[/img][font=res://assets/fonts/BagTooltip.tres]x " + str(reagent_types[key]) + "           [/font]"
	return tooltip

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = get_tooltip()
	TooltipLayer.add_tooltip(tooltip.pos, tooltip.title, tooltip.text, null, null, true, false, false)

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()
