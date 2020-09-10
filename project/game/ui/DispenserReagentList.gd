extends Control

signal dispenser_pressed

const DISPENSER = preload("res://game/ui/ReagentDispenser.tscn")

onready var list = $ScrollContainer/VBoxContainer

func populate(reagent_bag: Array):
	var reagents = {}
	
	for bag_reagent in reagent_bag:
		var type = bag_reagent.type
		if not reagents.has(type):
			reagents[type] = {
				"name": type,
				"amount": 1
			}
		else:
			reagents[type].amount += 1

	for reagent in reagents.values():
		var disp = DISPENSER.instance()
		disp.connect("dispenser_pressed", self, "_on_dispenser_pressed")
		list.add_child(disp)
		disp.setup(reagent.name, reagent.amount)

func get_dispenser(index):
	return list.get_child(index)

func clear():
	for disp in list.get_children():
		list.remove_child(disp)


func _on_dispenser_pressed(dispenser, reagent, quick_place):
	emit_signal("dispenser_pressed", dispenser, reagent, quick_place)
