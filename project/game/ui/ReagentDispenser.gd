extends Control

signal dispenser_pressed

onready var image = $HBoxContainer/Image
onready var label = $HBoxContainer/Label

var reagent_type
var quantity = 0
var max_quantity = 10

func setup(reagent, amount):
	reagent_type = reagent
	var reagent_data = ReagentDB.get_from_name(reagent_type)
	
	image.texture = reagent_data.image
	quantity = amount
	max_quantity = amount
	update_text()

func get_pos():
	return rect_global_position + rect_size/2

func get_quantity():
	return quantity

func set_quantity(value):
	quantity = value
	update_text()

func get_max_quantity():
	return max_quantity

func update_text():
	label.text = str(quantity) + "/" + str(max_quantity)

func _on_BGButton_button_down():
	AudioManager.play_sfx("click")
	if Input.is_action_pressed("right_mouse_button"):
		emit_signal("dispenser_pressed", self, reagent_type, true)
	else:
		emit_signal("dispenser_pressed", self, reagent_type, false)
