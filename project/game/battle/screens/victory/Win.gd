extends CanvasLayer

signal continue_pressed
signal reagent_looted(reagent_name)
signal reagent_sold(gold_value)

onready var loot_list = $BG/VBoxContainer/MarginContainer/VBoxContainer/LootList
onready var gold_label = $BG/VBoxContainer/MarginContainer/VBoxContainer/LootList/GoldReward/GoldLabel

const REAGENT_LOOT = preload("res://game/battle/screens/victory/ReagentLoot.tscn")


func set_loot(gold: int, loot: Array):
	gold_label.text = str(gold)
	
	for reagent_name in loot:
		var reagent_loot = REAGENT_LOOT.instance()
		loot_list.add_child(reagent_loot)
		reagent_loot.connect("reagent_looted", self, "_on_reagent_looted")
		reagent_loot.connect("reagent_sold", self, "_on_reagent_sold")
		reagent_loot.set_reagent(reagent_name)


func _on_Button_pressed():
	emit_signal("continue_pressed")


func _on_reagent_looted(reagent_loot):
	AudioManager.play_sfx("get_loot")
	emit_signal("reagent_looted", reagent_loot.reagent)
	reagent_loot.queue_free()


func _on_reagent_sold(reagent_loot):
	emit_signal("reagent_sold", reagent_loot.gold_value)
	reagent_loot.queue_free()


func _on_Button_button_down():
	AudioManager.play_sfx("click")


func _on_Button_mouse_entered():
		AudioManager.play_sfx("hover_button")
