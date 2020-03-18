extends Control

export(int) var room_amount := 15

enum {N, W, E, S}

const ROOM := preload("res://test/map/Room.tscn")
const INITIAL_POS := Vector2(688, 384)
const INITIAL_ROOM := -1
const OFFSETS := [Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1)]
const OPPOSITE := [S, E, W, N]

var remaining_rooms := room_amount
var remaining_exits := 0
var rooms := {}
var from_queue := []
var pos_queue := []

func _ready():
	Teste.counter += 1
	
	randomize()
	create_room(INITIAL_ROOM, Vector2())
	create_next_room()
	
#	for room in rooms.values():
#		room.update()
	
	assert(remaining_rooms == 0)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func create_room(from : int, position : Vector2):
	var room = ROOM.instance()
	room.position = position
	room.rect_position = INITIAL_POS + position * room.SIZE - room.SIZE / 2
	rooms[position] = room
	add_child(room)
	
	if from != INITIAL_ROOM:
		var previous_room = rooms[position + OFFSETS[from]]
		previous_room.exits[OPPOSITE[from]] = true
	
	var directions = [N, W, E, S]
	directions.shuffle()
	var avaiable_directions = []
	
	for dir in directions:
		if dir == from:
			room.exits[dir] = true
		elif not rooms.has(position + OFFSETS[dir]):
			avaiable_directions.append(dir)
			remaining_exits += 1
	
	for dir in avaiable_directions:
		if remaining_rooms == 0:
			break
		if randf() < remaining_rooms / float(room_amount) or\
				remaining_exits == 1:
			var target_pos = position + OFFSETS[dir]
			if not pos_queue.has(target_pos):
				from_queue.append(OPPOSITE[dir])
				pos_queue.append(target_pos)
				remaining_rooms -= 1
		
		remaining_exits -= 1


func create_next_room():
	if from_queue.size():
		create_room(from_queue.pop_front(), pos_queue.pop_front())
		create_next_room()
