extends Control

const STATUS = preload("res://game/character/Status.tscn")

export var two_rows := true

func _ready():
	if two_rows:
		$PositiveBG.show()
		$NegativeBG.show()
	else:
		$PositiveBG.hide()
		$NegativeBG.hide()

#Remove all status that are not in the status list
func clean_removed_status(status_list):
	if two_rows:
		for status in $PositiveStatus.get_children():
			if not status_list.has(status.type):
				remove_child(status)
		for status in $NegativeStatus.get_children():
			if not status_list.has(status.type):
				remove_child(status)
	else:
		for status in $Status.get_children():
			if not status_list.has(status.type):
				remove_child(status)

func get_status(type):
	if two_rows:
		for status in $PositiveStatus.get_children():
			if status.type == type:
				return status
		for status in $NegativeStatus.get_children():
			if status.type == type:
				return status
	else:
		for status in $Status.get_children():
			if status.type == type:
				return status

func get_status_tooltips():
	var tooltips = []
	
	if two_rows:
		for status in $PositiveStatus.get_children():
			tooltips.append(status.get_self_tooltip())
		for status in $NegativeStatus.get_children():
			tooltips.append(status.get_self_tooltip())
	else:
		for status in $Status.get_children():
			tooltips.append(status.get_self_tooltip())
	
	return tooltips

func set_status(type, value, positive):
	var status = get_status(type)
	if status:
		status.set_value(value)
	else:
		status = STATUS.instance()
		status.init(type, value, positive)
		if two_rows:
			if positive:
				$PositiveStatus.add_child(status)
			else:
				$NegativeStatus.add_child(status)
		else:
			$Status.add_child(status)
		sort_status()

#Sort status by positive/negative and then alphabetically
func sort_status():
	pass

func remove_status(type):
	if two_rows:
		for status in $PositiveStatus.get_children():
			if status.type == type:
				$PositiveStatus.remove_child(status)
		for status in $NegativeStatus.get_children():
			if status.type == type:
				$NegativeStatus.remove_child(status)
	else:
		for status in $Status.get_children():
			if status.type == type:
				$Status.remove_child(status)
	
