extends Control

signal closed

onready var title_label = $Title
onready var text_label = $VBox/TextRect/TextContainer/Text
onready var vbox = $VBox
onready var image = $Image

const IMAGES = [preload("res://assets/images/events/event_luck.png"),
		preload("res://assets/images/events/event_challenge.png"),
		preload("res://assets/images/events/event_tradeoff.png"),
		preload("res://assets/images/events/event_positive.png"),
		preload("res://assets/images/events/event_quest.png")]

var event : Event


func _ready():
# warning-ignore:return_value_discarded
	EventManager.connect("left", self, "_on_event_left")


func load_event(new_event: Event, player: Player, override_text: String = ""):
	event = new_event
	title_label.text = event.title
	if override_text != "":
		text_label.bbcode_text = override_text
	else:
		text_label.bbcode_text = event.text
	image.texture = IMAGES[event.type]
	
	for child in vbox.get_children():
		if child is Button:
			vbox.remove_child(child)
	
	for option in event.options:
		var button = Button.new()
		vbox.add_child(button)
		button.text = option.button_text
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", EventManager, option.callback,
				[self, player] + option.args)


func _on_event_left():
	emit_signal("closed")
