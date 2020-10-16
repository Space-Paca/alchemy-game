extends Node

var current_quest : Event = null
var events := {}
var event_list := []

func _ready():
	var dir := Directory.new()
	var path := "res://database/events/"
	if dir.open(path) == OK:
# warning-ignore:return_value_discarded
		dir.list_dir_begin()
		var file_name := dir.get_next() as String
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var event := load(str(path, file_name)) as Event
				events[event.id] = event
			file_name = dir.get_next()
	else:
		print("EventManager: An error occurred when trying to access the path.")


func reset_events():
	event_list.clear()
	
	for event in events.values():
		if event.type == Event.Type.QUEST and event.floor_appearance != 1:
			continue
		event_list.append(event)
	
	event_list.shuffle()


func get_random_event(current_floor: int) -> Event:
	var event : Event = null
	if current_quest:
		event = current_quest
		current_quest = null
	
	while not event:
		event = event_list.pop_front()
		if not event.floor_appearance[current_floor]:
			event_list.append(event)
			event = null
	
	return event
