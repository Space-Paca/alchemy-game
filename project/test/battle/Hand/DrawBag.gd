extends Node2D

signal reshuffled

var Hand = null #Setted by parent
var DiscardBag = null #Setted by parent
var Reagents = null #Setted by parent

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

func refill_hand():
	for _i in range(Hand.available_slot_count()):
		if $DrawableReagents.get_child_count() == 0:
			reshuffle()
			yield(self, "reshuffled")
		var reagent = draw_reagent()
		Hand.place_reagent(reagent)

#Shuffle discarded reagents in draw bag
func reshuffle():
	var discarded_reagents = DiscardBag.return_reagents()
	for reagent in discarded_reagents:
		reagent.visible = true
		Reagents.add_child(reagent)
		reagent.target_position = get_center()
		yield(reagent, "reached_target_pos")
		Reagents.remove_child(reagent)
		reagent.visible = false
		$DrawableReagents.add_child(reagent)
		update_counter()
	emit_signal("reshuffled")

#Gets and removes a random reagent from the bag
func draw_reagent():
	if $DrawableReagents.get_child_count() == 0:
		push_error('Not enough reagents')
		assert(false)
	#Remove reagent from draw bag
	var index = randi()%$DrawableReagents.get_child_count()
	var reagent = $DrawableReagents.get_child(index)
	$DrawableReagents.remove_child(reagent)
	update_counter()
	reagent.visible = true
	reagent.rect_position = get_center()
	Reagents.add_child(reagent)
	return reagent
		
