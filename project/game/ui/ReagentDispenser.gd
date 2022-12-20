extends Control

signal dispenser_pressed

const SEASONAL_MOD = {
	"halloween": {
		"ui": Color("ff9126"),
	},
	"eoy_holidays": {
		"ui": Color("00d3f6"),
	},
}

onready var image = $HBoxContainer/Image
onready var quantity_label = $HBoxContainer/Quantity
onready var name_label = $HBoxContainer/Name
onready var button = $BGButton

var reagent_type
var quantity = 0
var max_quantity = 10


func _ready():
	if Debug.seasonal_event:
		set_seasonal_look(Debug.seasonal_event)


func setup(reagent, amount):
	reagent_type = reagent
	var reagent_data = ReagentDB.get_from_name(reagent_type)
	
	image.texture = reagent_data.image
	name_label.text = reagent_data.name
	quantity = amount
	max_quantity = amount
	update_text()


func set_seasonal_look(event_string):
	button.self_modulate = SEASONAL_MOD[event_string].ui


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
	quantity_label.text = str(quantity) + "/" + str(max_quantity)


func enable():
	button.disabled = false


func disable():
	button.disabled = true


func _on_BGButton_button_down():
	AudioManager.play_sfx("click")
	if Input.is_action_pressed("right_mouse_button"):
		emit_signal("dispenser_pressed", self, reagent_type, true)
	else:
		emit_signal("dispenser_pressed", self, reagent_type, false)
