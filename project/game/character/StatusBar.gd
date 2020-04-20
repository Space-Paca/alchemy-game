extends HBoxContainer

const STATUS = preload("res://game/character/Status.tscn")

#Remove all status that are not in the status list
func clean_removed_status(status_list):
	for status in get_children():
		if not status_list.has(status.type):
			remove_child(status)

func get_status(type):
	for status in get_children():
		if status.type == type:
			return status

func set_status(type, value, positive):
	var status = get_status(type)
	if status:
		status.set_value(value)
	else:
		status = STATUS.instance()
		status.init(type, value, positive)
		add_child(status)
		sort_status()

#Sort status by positive/negative and then alphabetically
func sort_status():
	pass

func remove_status(type):
	var status = get_status(type)
	if status:
		remove_child(status)
	
