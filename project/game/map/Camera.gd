extends Camera2D

const INITIAL_POS = Vector2(960,540)

func get_offset():
	return position - INITIAL_POS
