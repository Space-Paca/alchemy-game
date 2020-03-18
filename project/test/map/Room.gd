extends TextureButton

enum {N, W, E, S}

const SIZE := Vector2(200, 150)

var exits := {N: false, W:false, E:false, S:false}
var position : Vector2


func _draw():
	if exits[N]:
		draw_line(Vector2(0 , 5), Vector2(80, 5), Color.black, 10)
		draw_line(Vector2(120, 5), Vector2(200, 5), Color.black, 10)
	else:
		draw_line(Vector2(0, 5), Vector2(200, 5), Color.black, 10)
	
	if exits[W]:
		draw_line(Vector2(5, 0), Vector2(5, 55), Color.black, 10)
		draw_line(Vector2(5, 95), Vector2(5, 150), Color.black, 10)
	else:
		draw_line(Vector2(5, 0), Vector2(5, 150), Color.black, 10)
	
	if exits[E]:
		draw_line(Vector2(195, 0), Vector2(195, 55), Color.black, 10)
		draw_line(Vector2(195, 95), Vector2(195, 150), Color.black, 10)
	else:
		draw_line(Vector2(195, 0), Vector2(195, 150), Color.black, 10)

	if exits[S]:
		draw_line(Vector2(0, 145), Vector2(80, 145), Color.black, 10)
		draw_line(Vector2(120, 145), Vector2(200, 145), Color.black, 10)
	else:
		draw_line(Vector2(0, 145), Vector2(200, 145), Color.black, 10)
