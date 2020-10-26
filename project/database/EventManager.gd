extends Node

signal left
signal gold_lost(amount)
signal gold_won(amount)

const FLOORS = [1, 2, 3]

var events_by_id := {}
var events_by_floor := {1: [], 2: [], 3: []}
var dummy_leave_event : Event
var current_quest : Event
var current_event : Event


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
				events_by_id[event.id] = event
			file_name = dir.get_next()
	else:
		print("EventManager: An error occurred when trying to access the path.")
	
	dummy_leave_event = events_by_id[-1]


func reset_events():
	for f in FLOORS:
		events_by_floor[f].clear()
	
	for event in events_by_id.values():
		for f in FLOORS:
			if event.floor_appearance[f]:
				events_by_floor[f].append(event)
	
	for f in FLOORS:
		events_by_floor[f].shuffle()


func get_random_event(current_floor: int) -> Event:
	assert(events_by_floor[current_floor].size())
	current_event = events_by_floor[current_floor].pop_front()
	return current_event


####### EVENT CALLBACKS #######

func none(_event_display):
	assert(false, "No callback set for this option")


func leave(_event_display):
	print("leave")
	emit_signal("left")


func load_leave_event(event_display, text: String, title := "", type := -1):
	dummy_leave_event.text = text
	dummy_leave_event.title = current_event.title if title == "" else title
	dummy_leave_event.type = current_event.type if type == -1 else type
	load_new_event(event_display, dummy_leave_event.id)


func load_new_event(event_display, new_event_id: int):
	event_display.load_event(events_by_id[new_event_id])


func bet(event_display, amount: int):
	if randf() > .5:
		emit_signal("gold_won", amount)
		load_leave_event(event_display, "Congratulations, you won %d gold!" % amount)
	else:
		emit_signal("gold_lost", amount)
		load_leave_event(event_display, "Too bad, you lost!")


func well(event_display, amount: int):
	var won = false
	if amount == 50:
		var rand = randf()
		if rand < .5:
			won = true
		elif rand < .9:
			## DAR ARTEFATO INCOMUM
			load_leave_event(event_display, "The well rewarded you with an uncommon artifact!")
			return
	else:
		var chance = {5: .1, 10: .25, 30: .8}
		won = randf() < chance[amount]
	
	if won:
		emit_signal("gold_won", 100 - amount)
		load_leave_event(event_display, "The well rewarded you with 100 gold!")
	else:
		emit_signal("gold_lost", amount)
		load_leave_event(event_display, "Nothing happened.")
