extends Control

signal closed_event
signal event_spawned_rest
signal event_spawned_battle(encounter)

onready var title_label = $Title
onready var text_label = $VBox/TextRect/TextContainer/Text
onready var vbox = $VBox
onready var image = $Image

const THEME = preload("res://assets/themes/event_theme/event_theme.tres")

var event : Event
var map_node : MapNode


func _ready():
# warning-ignore:return_value_discarded
	EventManager.connect("left_event", self, "_on_event_left")
# warning-ignore:return_value_discarded
	EventManager.connect("spawned_battle", self, "_on_event_spawned_battle")
# warning-ignore:return_value_discarded
	EventManager.connect("spawned_rest", self, "_on_event_spawned_rest")


func set_map_node(node: MapNode) -> void:
	map_node = node


func load_event(new_event: Event, player: Player, override_text: String = ""):
	event = new_event
	title_label.text = event.title
	if override_text != "":
		text_label.bbcode_text = override_text
	else:
		text_label.bbcode_text = event.text
	image.texture = EventManager.IMAGES[event.type]
	
	for child in vbox.get_children():
		if child is Button:
			vbox.remove_child(child)
	
	for option in event.options:
		var button = Button.new()
		vbox.add_child(button)
		button.text = "  -  " + option.button_text
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", EventManager, option.callback,
				[self, player] + option.args)
		button.theme = THEME


func _on_event_left():
	map_node.set_type(MapNode.EMPTY)
	emit_signal("closed_event")


func _on_event_spawned_battle(encounter: Encounter):
	emit_signal("event_spawned_battle", encounter)


func _on_event_spawned_rest():
	map_node.set_type(MapNode.REST)
	emit_signal("event_spawned_rest")
