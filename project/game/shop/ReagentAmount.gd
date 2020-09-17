extends HBoxContainer

onready var label = $Label
onready var reagent_display = $ReagentDisplay


func set_amount(amount: int):
	label.text = str("x ", amount)


func set_reagent(reagent_name: String):
	reagent_display.set_reagent(reagent_name)
