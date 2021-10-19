extends Camera2D

# Values of positional and rotational offsets when the screen shake is at its
# maximum
export(float) var max_angle = 10
export(float) var max_offset_x = 250
export(float) var max_offset_y = 250

# Affects how the current offset of the camera affects the offset in the next
# frame (0 = camera never moves, 1 = completely random shake).
export(float) var randomness = .3

# The ratio at which the screen shake decreases. It is multiplied by dt in
# process, so screen_shake goes from 1 to 0 in (1 / dec_ratio) seconds.
export(float) var dec_ratio = 1.2

# The exponent when factoring screen shake into the actual position and rotation
# offsets. Suggested value is between 2 and 3.
export(float) var exponent = 2

# A value representing current screen shake ranging from 0..1.
var screen_shake = 0

# A value representing priority of current shake (0 if not active)
var cur_priority := 0

# The actual range (also 0..1) that the positional and rotational offsets can be
# multiplied by.
var shake_factor = 0

# Current mode shake, continuous means shake doesn't decrease with time.
var continuous_shake := false


func _process(delta):
	if screen_shake == 0:
		offset = Vector2.ZERO
		cur_priority = 0
		set_process(false)
		return
	
	shake_factor = pow(screen_shake, exponent)
	
	var to_offset_x = rand_range(-1, 1) * shake_factor * max_offset_x
	var to_offset_y = rand_range(-1, 1) * shake_factor * max_offset_y
	var to_rotation = rand_range(-1, 1) * shake_factor * max_angle
	
	offset.x = lerp(offset.x, to_offset_x, randomness)
	offset.y = lerp(offset.y, to_offset_y, randomness)
	rotation_degrees = lerp(rotation_degrees, to_rotation, randomness)
	
	if not continuous_shake:
		screen_shake = max(0, screen_shake - dec_ratio * delta)


func shake(shake: float, priority : int) -> void:
	if priority > cur_priority:
		cur_priority = priority
		screen_shake = shake
	elif priority == cur_priority:
		screen_shake += shake
	else:
		return
	screen_shake = clamp(screen_shake, 0, 1)
	continuous_shake = false
	set_process(true)


func set_continuous_shake(shake: float, priority) -> void:
	if priority < cur_priority:
		return
	screen_shake = clamp(shake, 0, 1)
	if screen_shake == 0:
		continuous_shake = false
	else:
		continuous_shake = true
		set_process(true)
