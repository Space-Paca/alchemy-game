extends CanvasLayer

onready var rect = $ColorRect
onready var label = $ColorRect/Label
onready var tween = $Tween

const DUR = .7

var text_array := ["Welcome to Alchemia!\nA strategy turn-based roguelike, in which you'll have to learn and craft alchemical recipes to defeat enemies and progress to the end.", "In each run, you'll start at the lower \"floor\", and will have to uncover the map by defeating enemies and other peculiar encounters. Your objective is to find the boss and defeat it to progress.", "To defeat enemies, you'll have to craft recipes on your alchemical grid.\nEach recipe has an unique effect.", "You can always check your magical book to check which recipes you've learned, and even try incomplete recipes at your own risk.", "The battles are turn-based, so when you've made all moves you could,\nyou can pass the turn and the enemies will act.", "After each battle you'll earn your rewards to improve your character on this journey.", "There are over different 40 recipes to learn, almost 40 different enemies to encounter, special powerful artifacts to find, events and much more!", "We hope you'll enjoy Alchemia: Creatio Ex Nihilo and everything it has to offer!"]


func _input(event):
	if event.is_action_pressed("next_text"):
		next_text()
	elif event.is_action_pressed("close_text"):
		fade_out()


func next_text():
	if not text_array.size():
		return
	
	label.text = text_array.pop_front()
	fade_in()


func fade_in():
	tween.interpolate_property(rect, "modulate:a", 0, 1, DUR)
	tween.start()


func fade_out():
	tween.interpolate_property(rect, "modulate:a", 1, 0, DUR)
	tween.start()
