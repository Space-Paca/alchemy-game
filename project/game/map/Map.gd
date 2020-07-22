extends Control

onready var bg = $Background
onready var center_position = $FixedPositions/Center
onready var nodes = $Nodes
onready var positions = $FixedPositions

const MAP_NODE_SCENE = preload("res://game/map/MapNode.tscn")
const MAP_LINE = preload("res://game/map/MapLine.tscn")
const NODE_DIST = 200
const NODE_DIST_RAND = 50


func _ready():
	randomize()
	create_map(4, 2)
	
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func shift_positions():
	if randf() > .5:
		positions.rect_scale.x = -1
	if randf() > .5:
		positions.rect_rotation = 180
	
	positions.rect_rotation += 10 * (randf() * 2 - 1)


func validate_map(total_nodes:int, normal_enemies:int):
	var total_positions = positions.get_child_count() - 1 # -1 for initial node
	
	assert(total_positions >= total_nodes, "Map doesn't have enough positions")
	
	# Allocate initial position children as normal enemy nodes
	var unplaced_normal : int
	if center_position.children.size() > normal_enemies:
		unplaced_normal = 0
	else:
		unplaced_normal = normal_enemies - center_position.children.size()
	
	total_positions -= center_position.children.size()
	total_nodes = total_nodes - normal_enemies + unplaced_normal
	
	assert(total_positions >= total_nodes, "Map doesn't have enough positions")


func create_map(normal_encounters:int, elite_encounters:int, shops:int=1,
		rests:int=1, smiths:int=1, events:int=0):
	
	var total_nodes := normal_encounters + elite_encounters + shops + rests +\
			smiths + events + 1 # +1 for boss
	
	validate_map(total_nodes, normal_encounters)
	
	shift_positions()
	
	var initial_node : MapNode = MAP_NODE_SCENE.instance()
	nodes.add_child(initial_node)
	center_position.node = initial_node
	var available_starting_positions : Array = [center_position]
	var used_positions : Array = [center_position]
	var untyped_nodes := []
	
	while total_nodes:
		var starting_pos : MapPosition
		var new_pos : MapPosition
		
		# Draw a random starting position from the pool and a new position from
		# its children.
		prints("Total nodes:", total_nodes)
		print(available_starting_positions.size())
		print()
		starting_pos = available_starting_positions[\
				randi() % available_starting_positions.size()]
		starting_pos.children.shuffle()
		new_pos = starting_pos.get_node(starting_pos.children.pop_front())
		
		# Remove the starting position from the available ones if it has no more
		# children.
		if not starting_pos.children.size():
			available_starting_positions.erase(starting_pos)
		
		# If the new position was already used (possible because positions can
		# be reached from more than one path) make another draw.
		if new_pos in used_positions:
			continue
		
		# Also make another draw if the starting position is the overall initial
		# position and there are no more normal encounters to allocate.
		if starting_pos == center_position and normal_encounters == 0:
			continue
		
		used_positions.append(new_pos)
		
		if new_pos.children.size():
			available_starting_positions.append(new_pos)
		
		### NODE CREATION ###
		var new_node : MapNode = MAP_NODE_SCENE.instance()
		nodes.add_child(new_node)
		new_node.rect_global_position = new_pos.global_position
		new_pos.node = new_node
		starting_pos.node.is_leaf = false
		
		# Set new node type as enemy if it originated from the initial node
		if starting_pos == center_position:
			new_node.set_type(MapNode.ENEMY)
			normal_encounters -= 1
		else:
			untyped_nodes.append(new_node)
		
		### DEBUG LINE ###
#		var line = Line2D.new()
#		line.add_point(starting_pos.global_position)
#		line.add_point(new_pos.global_position)
#		bg.add_child(line)
		
		var map_line := MapLine.new()
		map_line.set_line(starting_pos.global_position, new_pos.global_position)
		bg.add_child(map_line)
		
		
		starting_pos.node.map_tree_children.append(new_node)
		total_nodes -= 1
	
	### TYPING NODES ###
	untyped_nodes.shuffle()
	
	for node in untyped_nodes:
		var map_node : MapNode = node
		if map_node.is_leaf:
			map_node.set_type(MapNode.BOSS)
			untyped_nodes.erase(map_node)
			break
	
	var count_by_type := [0, normal_encounters, elite_encounters, 0, shops,
			rests, smiths, events]
	
	for type in count_by_type.size():
		while count_by_type[type]:
			var map_node : MapNode = untyped_nodes.pop_front()
			map_node.set_type(type)
			count_by_type[type] -= 1
