extends HBoxContainer

const STATUS = preload("res://game/character/Status.tscn")

func get_status(type):
	for status in get_children():
		if status.type == type:
			return status

func set_status(type, value):
	var status = get_status(type)
	if status:
		status.set_value(value)
	else:
		status = STATUS.instance()
		status.init(type, value)
		add_child(status)
		

func remove_status(type):
	var status = get_status(type)
	if status:
		remove_child(status)
	
