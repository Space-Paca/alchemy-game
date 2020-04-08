extends Node2D

signal reshuffled
signal reagent_shuffled
signal hand_refilled
signal drew_given_reagents

var Hand = null #Set by parent
var DiscardBag = null #Set by parent
var Reagents = null #Set by parent


func _ready():
	$Center.position = $TextureRect.rect_size/2


func get_center():
	return $Center.global_position


func update_counter():
	$Counter.text = str($DrawableReagents.get_child_count())


func add_reagent(reagent):
	reagent.visible = false
	$DrawableReagents.add_child(reagent)
	update_counter()


func start_drawing(reagents):
	while not reagents.empty():
		var reagent = reagents.pop_back()
		Hand.place_reagent(reagent)
		if not reagents.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.2, .25)), "timeout")
		else:
			yield(Hand, "reagent_placed")
	emit_signal("drew_given_reagents")


func refill_hand():
	var reagents_to_be_drawn = []
	for _i in range(Hand.available_slot_count()):
		if $DrawableReagents.get_child_count() == 0:
			start_drawing(reagents_to_be_drawn)
			yield(self, "drew_given_reagents")
			yield(get_tree().create_timer(.5), "timeout")
			if not DiscardBag.is_empty():
				reshuffle()
				yield(self, "reshuffled")
				yield(get_tree().create_timer(.5), "timeout")
		
		reagents_to_be_drawn.append(draw_reagent())
	
	if not reagents_to_be_drawn.empty():
		start_drawing(reagents_to_be_drawn)
		yield(self, "drew_given_reagents")
	
	emit_signal("hand_refilled")


#Shuffle discarded reagents in draw bag
func reshuffle():
	var discarded_reagents = DiscardBag.return_reagents()
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
	Reagents.add_child(reagent)
	reagent.target_position = get_center()
	yield(reagent, "reached_target_pos")
	Reagents.remove_child(reagent)
	reagent.visible = false
	$DrawableReagents.add_child(reagent)
	update_counter()
	emit_signal("reagent_shuffled")


#Gets and removes a random reagent from the bag
func draw_reagent():
	if $DrawableReagents.get_child_count() == 0:
		push_error('Not enough reagents')
		assert(false)
	#Remove reagent from draw bag
	randomize()
	var index = randi()%$DrawableReagents.get_child_count()
	var reagent = $DrawableReagents.get_child(index)
	$DrawableReagents.remove_child(reagent)
	update_counter()
	reagent.visible = true
	reagent.rect_position = get_center()
	Reagents.add_child(reagent)
	return reagent
