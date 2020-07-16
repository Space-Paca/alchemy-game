extends Control

onready var bg = $Background
onready var nodes = $Nodes

const MAP_NODE_SCENE = preload("res://game/map/MapNode.tscn")
const NODE_DIST = 200
const NODE_DIST_RAND = 50


func _ready():
	randomize()
	create_map(2, 2)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func create_map(normal_encounters:int, elite_encounters:int, shops:int=1,
		rests:int=1, smiths:int=1):
	var total_nodes := normal_encounters+elite_encounters+shops+rests+smiths+1 # +1 for boss
	var count_by_type := [0, normal_encounters, elite_encounters, 0, shops, rests, smiths]
	
	var initial_node = MAP_NODE_SCENE.instance()
	nodes.add_child(initial_node)
	
	while total_nodes:
		var origin_node : MapNode = nodes.get_child(randi() % nodes.get_child_count())
		var position_offset
		var new_node = MAP_NODE_SCENE.instance()
		nodes.add_child(new_node)
		origin_node.is_leaf = false
		
		position_offset = Vector2(NODE_DIST+rand_range(-1, 1)*NODE_DIST_RAND, 0)
		new_node.rect_position = origin_node.rect_position + position_offset.rotated(randf()*2*PI)
		
		var line = Line2D.new()
		line.add_point(origin_node.rect_global_position)
		line.add_point(new_node.rect_global_position)
		bg.add_child(line)
		
		total_nodes -= 1
	
	var all_nodes = nodes.get_children()
	all_nodes.erase(initial_node)
	all_nodes.shuffle()
	
	for node in all_nodes:
		if node.is_leaf:
			node.set_type(MapNode.BOSS)
			all_nodes.erase(node)
			break
	
	for type in count_by_type.size():
		while count_by_type[type]:
			var map_node : MapNode = all_nodes.pop_front()
			map_node.set_type(type)
			count_by_type[type] -= 1
