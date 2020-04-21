extends Node2D

onready var center = $Center
onready var counter = $Counter
onready var drawable_reagents = $DrawableReagents

signal reshuffled
signal reagent_shuffled
signal hand_refilled
signal given_reagents_drawn

var hand = null #Set by parent
var discard_bag = null #Set by parent
var reagents = null #Set by parent


func _ready():
	center.position = $TextureRect.rect_size/2


func get_center():
	return center.global_position


func update_counter():
	counter.text = str(drawable_reagents.get_child_count())


func add_reagent(reagent):
	reagent.visible = false
	drawable_reagents.add_child(reagent)
	update_counter()

func get_width():
	return $TextureRect.rect_size.x

func get_height():
	return $TextureRect.rect_size.y

func start_drawing(_reagents):
	while not _reagents.empty():
		var reagent = _reagents.pop_back()
		reagent.disable_dragging()
		hand.place_reagent(reagent)
		if not _reagents.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.2, .25)), "timeout")
		else:
			yield(hand, "reagent_placed")
	emit_signal("given_reagents_drawn")


func refill_hand():
	var reagents_to_be_drawn = []
	for _i in range(hand.available_slot_count()):
		if drawable_reagents.get_child_count() == 0:
			if not reagents_to_be_drawn.empty():
				start_drawing(reagents_to_be_drawn)
				yield(self, "given_reagents_drawn")
			yield(get_tree().create_timer(.5), "timeout")
			if not discard_bag.is_empty():
				reshuffle()
				yield(self, "reshuffled")
				yield(get_tree().create_timer(.5), "timeout")
			else:
				break

		reagents_to_be_drawn.append(draw_reagent())
	
	if not reagents_to_be_drawn.empty():
		start_drawing(reagents_to_be_drawn)
		yield(self, "given_reagents_drawn")
	
	emit_signal("hand_refilled")


#Shuffle discarded reagents in draw bag
func reshuffle():
	var discarded_reagents = discard_bag.return_reagents()
	while not discarded_reagents.empty():
		var reagent = discarded_reagents.pop_back()
		shuffle_reagent(reagent)
		if not discarded_reagents.empty():
			yield(get_tree().create_timer(rand_range(.3, .4)), "timeout")
		else:
			yield(self, "reagent_shuffled")
	emit_signal("reshuffled")


func shuffle_reagent(reagent):
	reagent.visible = true
	reagents.add_child(reagent)
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
	#Remove reagent from draw bag
	randomize()
	var index = randi() % drawable_reagents.get_child_count()
	var reagent = drawable_reagents.get_child(index)
	drawable_reagents.remove_child(reagent)
	update_counter()
	reagent.visible = true
	reagent.rect_position = get_center()
	reagents.add_child(reagent)
	return reagent
