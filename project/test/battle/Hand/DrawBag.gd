extends Node2D

var Hand = null #Setted by parent
var Reagents = null #Setted by parent

func _ready():
	$Center.position = $TextureRect.rect_size/2

func get_center():
	return $Center.global_position

func add_reagent(reagent):
	reagent.visible = false
	$Reagents.add_child(reagent)

func refill_hand():
	for _i in range(Hand.available_slot_count()):
		var reagent = draw_reagent()
		Hand.place_reagent(reagent)

#Gets and removes a random reagent from the bag
func draw_reagent():
	var reagents_count = $Reagents.get_child_count()
	if reagents_count > 0:
		var index = randi()%$Reagents.get_child_count()
		var reagent = $Reagents.get_child(index)
		$Reagents.remove_child(reagent)
		reagent.visible = true
		reagent.rect_position = get_center()
		Reagents.add_child(reagent)
		return reagent
	else:
		pass
