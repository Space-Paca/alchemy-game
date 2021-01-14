extends HBoxContainer

onready var label = $Label
onready var reagent_display = $ReagentDisplay


func set_amount(amount: int):
	label.text = str("x ", amount)


func set_reagent(reagent_name: String):
	reagent_display.set_reagent(reagent_name)
	reagent_display.set_mode("blank")


func disable_tooltips():
	reagent_display.disable_tooltips()


func enable_tooltips():
	reagent_display.enable_tooltips()
