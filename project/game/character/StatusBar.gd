extends Control

const STATUS = preload("res://game/character/Status.tscn")


func setup(width):
		$Status.rect_size.x = width


func get_height():
	return $Status.rect_size.y


#Remove all status that are not in the status list
func clean_removed_status(status_list):
	for status in $Status.get_children():
		if not status_list.has(status.type):
			$Status.remove_child(status)


func get_status(type):
	for status in $Status.get_children():
		if status.type == type:
			return status


func get_status_tooltips():
	var tooltips = []
	
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
		$Status.add_child(status)
		sort_status()


#Sort status by positive/negative and then alphabetically
func sort_status():
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
	for status in $Status.get_children():
		if status.type == type:
			$Status.remove_child(status)
