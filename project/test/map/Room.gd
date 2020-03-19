extends TextureButton

enum {N, W, E, S}

const SIZE := Vector2(160, 90)

var exits := {N: false, W:false, E:false, S:false}
var position : Vector2


func _draw():
	var width = 4
	var w2 = width / 2
	var gap = 20
	
	if exits[N]:
		draw_line(Vector2(0 , w2), Vector2(SIZE.x / 2 - gap, w2), Color.black, width)
		draw_line(Vector2(SIZE.x / 2 + gap, w2), Vector2(SIZE.x, w2), Color.black, width)
	else:
		draw_line(Vector2(0, w2), Vector2(SIZE.x, w2), Color.black, width)
	
	if exits[W]:
		draw_line(Vector2(w2, 0), Vector2(w2, SIZE.y / 2 - gap), Color.black, width)
		draw_line(Vector2(w2, SIZE.y / 2 + gap), Vector2(w2, SIZE.y), Color.black, width)
	else:
		draw_line(Vector2(w2, 0), Vector2(w2, SIZE.y), Color.black, width)
	
	if exits[E]:
		draw_line(Vector2(SIZE.x - w2, 0), Vector2(SIZE.x - w2, SIZE.y / 2 - gap), Color.black, width)
		draw_line(Vector2(SIZE.x - w2, SIZE.y / 2 + gap), Vector2(SIZE.x - w2, SIZE.y), Color.black, width)
	else:
		draw_line(Vector2(SIZE.x - w2, 0), Vector2(SIZE.x - w2, SIZE.y), Color.black, width)

	if exits[S]:
		draw_line(Vector2(0, SIZE.y - w2), Vector2(SIZE.x / 2 - gap, SIZE.y - w2), Color.black, width)
		draw_line(Vector2(SIZE.x / 2 + gap, SIZE.y - w2), Vector2(SIZE.x, SIZE.y - w2), Color.black, width)
	else:
		draw_line(Vector2(0, SIZE.y - w2), Vector2(SIZE.x, SIZE.y - w2), Color.black, width)
