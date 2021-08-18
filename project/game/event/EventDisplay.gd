extends Control

signal closed_event
signal event_spawned_rest
signal event_spawned_battle(encounter)

onready var title_label = $Title
onready var text_label = $VBox/TextRect/TextContainer/Text
onready var vbox = $VBox
onready var image = $Image
onready var tween = $Tween

const THEME = preload("res://assets/themes/event_theme/event_theme.tres")
# Text effects
const FORMAT_DICT = {
		"(highlight)": "[color=#ffff00]",
		"(/highlight)": "[/color]",
		"(shake)": "[shake]",
		"(/shake)": "[/shake]",
		"(small)": "[i]",
		"(/small)": "[/i]",
		"(wave)": "[wave amp=50 freq=2]",
		"(/wave)": "[/wave]"
}
const TEXT_SPEED = 150

var event : Event
var map_node : MapNode


func _ready():
# warning-ignore:return_value_discarded
	EventManager.connect("left_event", self, "_on_event_left")
# warning-ignore:return_value_discarded
	EventManager.connect("spawned_battle", self, "_on_event_spawned_battle")
# warning-ignore:return_value_discarded
	EventManager.connect("spawned_rest", self, "_on_event_spawned_rest")
# warning-ignore:return_value_discarded
#	Transition.connect("finished", self, "_on_Transition_finished")


func set_map_node(node: MapNode) -> void:
	map_node = node


func load_event(new_event: Event, player: Player, override_text: String = ""):
	event = new_event
	title_label.text = tr(event.title)
	if override_text != "":
		text_label.bbcode_text = translate_and_format(override_text)
	else:
		text_label.bbcode_text = translate_and_format(event.text)
	text_label.percent_visible = 0
	image.texture = EventManager.IMAGES[event.type]
	
	for child in vbox.get_children():
		if child is Button:
			vbox.remove_child(child)
	
	for option in event.options:
		var button = Button.new()
		vbox.add_child(button)
		button.text = "  -  " + tr(option.button_text)
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", EventManager, option.callback,
				[self, player] + option.args)
		button.theme = THEME
		button.disabled = true
		button.modulate.a = 0
	
	tween.stop_all()
	
	if Transition.active:
		yield(Transition, "finished")
	else:
		yield(get_tree(), "idle_frame")
	
	animate_text(text_label.get_total_character_count() / TEXT_SPEED)


func translate_and_format(text: String) -> String:
	text = tr(text)
	for key in FORMAT_DICT.keys():
		for i in text.count(key):
			text = text.replace(key, FORMAT_DICT[key])
	
	return text


func animate_text(duration: float):
	if text_label.percent_visible:
		return
	tween.interpolate_property(text_label, "percent_visible", 0, 1, duration)
	tween.start()
	
	yield(tween, "tween_completed")
	
	for button in vbox.get_children():
		if button is Button:
			tween.interpolate_property(button, "modulate:a", 0, 1, .5)
			tween.start()
			yield(tween, "tween_completed")
	
	for button in vbox.get_children():
		if button is Button:
			button.disabled = false


func _on_event_left():
	map_node.set_type(MapNode.EMPTY)
	emit_signal("closed_event")


func _on_event_spawned_battle(encounter: Encounter):
	emit_signal("event_spawned_battle", encounter)


func _on_event_spawned_rest():
	map_node.set_type(MapNode.REST)
	emit_signal("event_spawned_rest")
