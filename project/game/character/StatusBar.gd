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
				$PositiveStatus.remove_child(status)
		for status in $NegativeStatus.get_children():
			if not status_list.has(status.type):
				$NegativeStatus.remove_child(status)
	else:
		for status in $Status.get_children():
			if not status_list.has(status.type):
				$Status.remove_child(status)

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
	if two_rows:
		sort_status_bar($PositiveStatus)
		sort_status_bar($NegativeStatus)
	else:
		sort_status_bar($Status)

#Insert sort using positive/negative then name as comparison
func sort_status_bar(bar):
	var status_pos = []
	for status in bar.get_children():
		var i = 0
		while i < status_pos.size():
			var status2 = status_pos[i]
			if (status.positive and not status2.positive) or \
			   (status.positive == status2.positive and status.type < status2.type):
				break
			i += 1
		status_pos.insert(i, status)
	for i in range(status_pos.size()):
		bar.move_child(status_pos[i], i)

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
	
