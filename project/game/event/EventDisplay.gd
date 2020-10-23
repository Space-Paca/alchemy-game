extends Control

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
	EventManager.reset_events()
	load_event(EventManager.get_random_event(1))


func load_event(new_event: Event):
	event = new_event
	title_label.text = event.title
	text_label.text = event.text
	image.texture = IMAGES[event.type]
	
	for child in vbox.get_children():
		if child is Button:
			vbox.remove_child(child)
	
	for option in event.options:
		var button = Button.new()
		vbox.add_child(button)
		button.text = option.button_text
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", EventManager, option.callback, [self] + option.args)

