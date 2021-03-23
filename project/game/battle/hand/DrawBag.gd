extends Node2D

onready var center = $Center
onready var counter = $TextureRect/Counter
onready var drawable_reagents = $DrawableReagents

const TOOLTIP_LINE_HEIGHT = 34

signal reshuffled
signal reagent_shuffled
signal hand_refilled
signal given_reagents_drawn
signal drew_reagents

var hand = null #Set by parent
var discard_bag = null #Set by parent
var reagents = null #Set by parent
var player = null #Set by parent
var tooltips_enabled := false
var block_tooltips := false
var forced_draw_faint := false
var forced_draw_damage := false


func _ready():
	center.position = $TextureRect.rect_size/2

func disable():
	disable_tooltips()
	block_tooltips = true

func enable():
	block_tooltips = false


func get_data():
	var data = []
	for reagent in drawable_reagents.get_children():
		data.append(reagent.get_data())
	
	return data


func copy_bag(other_bag):
	for c in drawable_reagents.get_children():
		drawable_reagents.remove_child(c)
	
	for reagent in other_bag.drawable_reagents.get_children():
		var reagent_object = ReagentManager.create_object(reagent.type)
		add_reagent(reagent_object, false)
	
	update_counter()

func get_center():
	return center.global_position

#Gets a fake amount to update counter with animation effect
func update_counter(fake_amount := 0):
	counter.text = str(drawable_reagents.get_child_count() + fake_amount)


func get_reagent_names() -> Array:
	var names := []
	for reagent in drawable_reagents.get_children():
		names.append(reagent.type)
	return names


func add_reagent(reagent, should_update_counter: = true):
	reagent.disable_tooltips()
	reagent.disable_dragging()
	reagent.visible = false
	drawable_reagents.add_child(reagent)
	if should_update_counter:
		update_counter()

func get_width():
	return $TextureRect.rect_size.x

func get_height():
	return $TextureRect.rect_size.y

func start_drawing(_reagents):
	while not _reagents.empty():
		var reagent = _reagents.pop_back()
		reagent.disable_dragging()
		AudioManager.play_sfx("draw_reagent")
		reagent.grow()
		reagent.rect_scale = Vector2(0,0)
		hand.place_reagent(reagent)
		reagent.enable_tooltips()
		update_counter(_reagents.size())
		if not _reagents.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.05, .1)), "timeout")
		else:
			yield(hand, "reagent_placed")
	emit_signal("given_reagents_drawn")

func refill_hand():
	var status = player.get_status("time_bomb")
	var unstable_n = 0 if not status else status.amount

	var reagents_to_be_drawn = []
	for _i in range(hand.available_slot_count()):
		if drawable_reagents.get_child_count() == 0:
			if not reagents_to_be_drawn.empty():
				start_drawing(reagents_to_be_drawn)
				yield(self, "given_reagents_drawn")
			yield(get_tree().create_timer(.25), "timeout")
			if not discard_bag.is_empty():
				reshuffle()
				yield(self, "reshuffled")
				yield(get_tree().create_timer(.25), "timeout")
			else:
				break
		
		var reagent = draw_reagent()
		if unstable_n > 0:
			unstable_n -= 1
			reagent.toggle_unstable()

		reagents_to_be_drawn.append(reagent)
	
	if not reagents_to_be_drawn.empty():
		start_drawing(reagents_to_be_drawn)
		yield(self, "given_reagents_drawn")
	
	emit_signal("hand_refilled")

func draw_reagents(amount: int):
	var reagents_to_be_drawn = []
# warning-ignore:narrowing_conversion
	amount = min(amount, hand.available_slot_count())
	if amount <= 0:
		return
	for _i in range(amount):
		if drawable_reagents.get_child_count() == 0:
			if not reagents_to_be_drawn.empty():
				start_drawing(reagents_to_be_drawn)
				yield(self, "given_reagents_drawn")
			yield(get_tree().create_timer(.25), "timeout")
			if not discard_bag.is_empty():
				reshuffle()
				yield(self, "reshuffled")
				yield(get_tree().create_timer(.25), "timeout")
			else:
				break

		reagents_to_be_drawn.append(draw_reagent())
	
	if not reagents_to_be_drawn.empty():
		start_drawing(reagents_to_be_drawn)
		yield(self, "given_reagents_drawn")
	
	emit_signal("drew_reagents")


#Shuffle discarded reagents in draw bag
func reshuffle():
	var discarded_reagents = discard_bag.return_reagents()
	while not discarded_reagents.empty():
		var reagent = discarded_reagents.pop_back()
		shuffle_reagent(reagent)
		if not discarded_reagents.empty():
			yield(get_tree().create_timer(rand_range(.01, .05)), "timeout")
		else:
			yield(self, "reagent_shuffled")
	emit_signal("reshuffled")


func shuffle_reagent(reagent):
	reagent.visible = true
	reagents.add_child(reagent)
	reagent.grow_and_shrink()
	reagent.target_position = get_center()
	yield(reagent, "reached_target_pos")
	reagents.remove_child(reagent)
	reagent.visible = false
	drawable_reagents.add_child(reagent)
	update_counter()
	emit_signal("reagent_shuffled")


#Gets and removes a random reagent from the bag
func draw_reagent():
	if drawable_reagents.get_child_count() == 0:
		push_error('Not enough reagents')
		assert(false)
	
	var index = -1
	#Guarantee player gets a faint and damage reagent for tutorial purposes
	if not Profile.get_tutorial("clicked_recipe") and not (forced_draw_faint and forced_draw_damage):
		if not forced_draw_faint:
			forced_draw_faint = true
			for i in drawable_reagents.get_child_count():
				if drawable_reagents.get_child(i).type == "faint":
					index = i
					break
			if index == -1:
				assert(index, "Couldn't find a forced faint index for tutorial")
				randomize()
				index = randi() % drawable_reagents.get_child_count()
		elif not forced_draw_damage:
			forced_draw_damage = true
			for i in drawable_reagents.get_child_count():
				if drawable_reagents.get_child(i).type == "weak_damaging":
					index = i
					break
			if index == -1:
				assert(index, "Couldn't find a forced damage index for tutorial")
				randomize()
				index = randi() % drawable_reagents.get_child_count()
	#Remove reagent from draw bag
	else:
		randomize()
		index = randi() % drawable_reagents.get_child_count()
	
	var reagent = drawable_reagents.get_child(index)
	drawable_reagents.remove_child(reagent)
	update_counter()
	reagent.visible = true
	reagent.rect_position = get_center()
	reagent.rect_scale = Vector2(0,0)
	reagents.add_child(reagent)
	return reagent


func draw_specific_reagent(reagent):
	drawable_reagents.remove_child(reagent)
	update_counter()
	reagent.visible = true
	reagent.rect_position = get_center()
	reagent.rect_scale = Vector2(0,0)
	reagents.add_child(reagent)
	return reagent


func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()
		
func get_tooltip():
	var tooltip = {}
	tooltip.title = "Draw Bag"
	tooltip.text = ""
	var reagent_types = {}
	for reagent in $DrawableReagents.get_children():
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
		#For some reason \n just erases other images, so using gambiara to properly change lines
		tooltip.text += "[img=40x40]"+path+"[/img][font=res://assets/fonts/BagTooltip.tres]x" + str(reagent_types[key]) + "[/font]"
	return tooltip

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = get_tooltip()
	TooltipLayer.add_tooltip(tooltip.pos, tooltip.title, tooltip.text, null, null, true, false, false)
