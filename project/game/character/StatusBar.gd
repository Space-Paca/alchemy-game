extends Control

const STATUS = preload("res://game/character/Status.tscn")
const BG_MARGIN_X = 40
const BG_MARGIN_Y = 10
const SCALE_SPEED = 6.5
const EPSILON = .01

func _ready():
	$BG.rect_position.x = -BG_MARGIN_X*$BG.rect_scale.x
	$BG.rect_position.y = -BG_MARGIN_Y
	$BG.rect_scale.x = 0


func _process(dt):
	var sx = get_target_bg_scale()
	#Update scale
	var speed = SCALE_SPEED if sx else 2.6*SCALE_SPEED
	$BG.rect_scale.x += (sx - $BG.rect_scale.x)*min(speed*dt,1)
	if abs(sx - $BG.rect_scale.x) <= EPSILON:
		$BG.rect_scale.x = sx
	#Update position
	$BG.rect_position.x = -BG_MARGIN_X*$BG.rect_scale.x
	if sx <= 0:
		$BG.modulate.a = min($BG.rect_scale.x, 1.0)
	else:
		$BG.modulate.a = 1.0


func setup(width):
	$Status.rect_size.x = width


func get_height():
	return $Status.rect_size.y

func disable():
	for status in $Status.get_children():
		status.disable()

func enable():
	for status in $Status.get_children():
		status.enable()


func get_target_bg_scale():
	if $Status.get_child_count() == 0:
		return 0
	else:
		var last_status = $Status.get_child(($Status.get_child_count() - 1))
		var w = last_status.rect_position.x + last_status.rect_size.x
		return w/float($BG.rect_size.x - 2*BG_MARGIN_X)

		


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
