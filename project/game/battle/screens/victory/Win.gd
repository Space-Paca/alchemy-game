extends CanvasLayer

signal continue_pressed
signal reagent_looted(reagent_name)

onready var reagents = $BG/VBoxContainer/MarginContainer/VBoxContainer/Reagents

const REAGENT_LOOT = preload("res://game/battle/screens/victory/ReagentLoot.tscn")


func set_loot(loot: Array):
	for reagent_name in loot:
		var reagent_loot = REAGENT_LOOT.instance()
		reagents.add_child(reagent_loot)
		reagent_loot.connect("reagent_looted", self, "_on_reagent_looted")
		reagent_loot.set_reagent(reagent_name)


func _on_Button_pressed():
	AudioManager.play_sfx("click")
	emit_signal("continue_pressed")


func _on_reagent_looted(reagent_loot):
	reagents.remove_child(reagent_loot)
	emit_signal("reagent_looted", reagent_loot.reagent)
