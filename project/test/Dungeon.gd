extends Control

export(int) var room_amount := 5

enum {N, W, E, S}

const ROOM := preload("res://test/Room.tscn")
const INITIAL_POS := Vector2(688, 384)
const INITIAL_ROOM := -1
const OFFSETS := [Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1)]
const OPPOSITE := [S, E, W, N]

var remaining_rooms := room_amount
var remaining_exits := 0
var rooms := {}
var room_queue := []

var counter := 0

func _ready():
	randomize()
	create_room(INITIAL_ROOM, Vector2())
	create_next_room()


func create_room(from : int, position : Vector2):
	var room = ROOM.instance()
	room.position = position
	room.rect_position = INITIAL_POS + position * room.SIZE - room.SIZE / 2
	rooms[position] = room
	add_child(room)
	remaining_rooms -= 1
	
	var directions = [N, W, E, S]
	directions.shuffle()
	print(directions)
	var avaiable_directions = []
	
	for dir in directions:
		if dir == from:
			room.exits[dir] = true
		elif not rooms.has(position + OFFSETS[dir]):
			avaiable_directions.append(dir)
			remaining_exits += 1
	
	if remaining_rooms == 0:
		return
	
	for dir in avaiable_directions:
		if randf() < remaining_rooms / float(room_amount) or\
				remaining_exits == 1:
			room.exits[dir] = true
			room_queue.append([OPPOSITE[dir], position + OFFSETS[dir]])
		
		remaining_exits -= 1


func create_next_room():
	var room_info = room_queue.pop_front()
	if room_info:
		create_room(room_info[0], room_info[1])
		create_next_room()
