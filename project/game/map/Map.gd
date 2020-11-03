extends Control
class_name Map

signal map_node_pressed(node)

onready var bg = $Background
onready var lines = $Lines
onready var camera = $Camera
onready var click_block = $ClickBlock
onready var nodes = $Nodes
onready var floor_label = $CanvasLayer/FloorLabel
onready var player_info = $CanvasLayer/PlayerInfo

const MAP_NODE_SCENE = preload("res://game/map/MapNode.tscn")
const MAP_LINE = preload("res://game/map/MapLine.tscn")
const NODE_DIST = 200
const NODE_DIST_RAND = 50
const CAMERA_LINEAR_SPEED = 60
const CAMERA_EXPONENTIAL_SPEED = .1
const EPSLON = 1
const CENTRAL_NODE_CHILDREN_SIZE = 2

var active_paths := 0
var active_nodes := []
var initial_node : MapNode
var current_level : int setget set_level
var update_camera := true
var camera_last_pos = false
var stored_map_positions = null
var positions = null
var center_position = null


func _ready():
	stored_map_positions = $FixedPositions.duplicate(7)


func _process(dt):
	if update_camera:
		#Get camera target pos
		var target_pos = Vector2(0,0)
		var count = 0
		for node in active_nodes:
			count += 1
			target_pos += node.rect_position
		
		if count > 0:
			target_pos = target_pos/float(count)
			target_pos += get_screen_center()
			
			#Move camera linearly
			var dist = (target_pos - $Camera.position)
			if CAMERA_LINEAR_SPEED*dt < 3*dist.length():
				$Camera.position += dist.normalized()*CAMERA_LINEAR_SPEED*dt
			else:
				$Camera.position += dist*CAMERA_EXPONENTIAL_SPEED*dt
			
			if (target_pos - $Camera.position).length() <= EPSLON:
				$Camera.position = target_pos


func set_disabled(toggle:bool):
	click_block.visible = toggle


func enable():
	show()
	floor_label.show()
	player_info.show()
	update_camera = true
	if camera_last_pos:
		camera.position = camera_last_pos


func disable():
	hide()
	floor_label.hide()
	player_info.hide()
	update_camera = false
	camera_last_pos = camera.position
	reset_camera()


func recipe_toogle(active : bool):
	if not visible:
		return
	if active:
		floor_label.hide()
		player_info.hide()
	else:
		floor_label.show()
		player_info.show()


func set_level(level:int):
	current_level = level
	floor_label.text = str("Floor ", current_level)


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


func get_screen_center():
	return Vector2(1920/2, 1080/2)


func reset_camera():
	$Camera.position = get_screen_center()


func create_map(normal_encounters:int, elite_encounters:int, smiths:int=1,
		rests:int=1, shops:int=1, events:int=1, labs:int=1, treasures:int=1):
	
	#Reset Stored Positions
	var old_positions = get_node("FixedPositions")
	if old_positions:
		remove_child(old_positions)
		old_positions.queue_free()
	positions = stored_map_positions.duplicate(7)
	center_position = positions.get_node("Center")
	#Reduce randomly number of childs center node has
	center_position.children.shuffle()
	while center_position.children.size() > CENTRAL_NODE_CHILDREN_SIZE:
		center_position.children.remove(1)
	
	add_child_below_node(nodes, positions)
	
	reset_camera()
	active_nodes = []
	camera_last_pos = false
	
	var total_nodes := normal_encounters + elite_encounters + shops + rests +\
			smiths + events + labs + treasures + 1
	
	validate_map(total_nodes, normal_encounters)
	
	shift_positions()
	
	initial_node = MAP_NODE_SCENE.instance()
	initial_node.set_camera($Camera)
	nodes.add_child(initial_node)
	active_nodes.append(initial_node)
	center_position.node = initial_node
	var available_starting_positions : Array = [center_position]
	var used_positions : Array = [center_position]
	var untyped_nodes := []
	
	while total_nodes:
		var starting_pos : MapPosition
		var new_pos : MapPosition
		
		# Draw a random starting position from the pool and a new position from
		# its children.
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
		new_node.disable()
		new_node.modulate.a = 0
		new_node.set_camera($Camera)
		nodes.add_child(new_node)
		new_node.rect_global_position = new_pos.global_position
		new_pos.node = new_node
		starting_pos.node.is_leaf = false
		starting_pos.node.map_tree_children.append(new_node)
# warning-ignore:return_value_discarded
		new_node.connect("pressed", self, "_on_map_node_clicked", [new_node])
		
		# Set new node type as enemy if it originated from the initial node
		if starting_pos == center_position:
			new_node.set_type(MapNode.ENEMY)
			normal_encounters -= 1
		else:
			untyped_nodes.append(new_node)
		
		# Add map line
		var map_line := MapLine.new()
		map_line.set_line(starting_pos.global_position, new_pos.global_position)
		lines.add_child(map_line)
		starting_pos.node.map_lines.append(map_line)
		
		total_nodes -= 1
	
	### TYPING NODES ###
	untyped_nodes.shuffle()
	
	#Setting up boss and elite encounters
	var boss_placed = false
	var to_erase = []
	for node in untyped_nodes:
		var map_node : MapNode = node
		if map_node.is_leaf and not boss_placed:
			map_node.set_type(MapNode.BOSS)
			to_erase.append(map_node)
			boss_placed = true
		elif map_node.is_leaf and elite_encounters > 0:
			map_node.set_type(MapNode.ELITE)
			to_erase.append(map_node)
			elite_encounters -= 1
			if elite_encounters <= 0:
				break
	
	for map_node in to_erase:
		untyped_nodes.erase(map_node)

	var count_by_type := [0, normal_encounters, elite_encounters, 0, shops,
			rests, smiths, events, labs, treasures]
	
	for type in count_by_type.size():
		while count_by_type[type]:
			var map_node : MapNode = untyped_nodes.pop_front()
			map_node.set_type(type)
			count_by_type[type] -= 1
	
	positions.queue_free()
	reveal_paths(initial_node)


func reveal_paths(node:MapNode):
	if node.paths_revealed:
		return
	
	for i in node.map_tree_children.size():
		var line : MapLine = node.map_lines[i]
		var child_node : MapNode = node.map_tree_children[i]
		active_nodes.append(child_node)
# warning-ignore:return_value_discarded
		line.connect("filled", self, "_on_path_reached", [child_node])
		line.begin_fill()
		active_paths += 1
	
	node.paths_revealed = true
	
	if active_paths:
		set_disabled(true)


func _on_path_reached(node:MapNode):
	node.fade_in()
	node.enable()
	if node.should_autoreveal():
		reveal_paths(node)
	
	active_paths -= 1
	
	if not active_paths:
		set_disabled(false)


func _on_map_node_clicked(node:MapNode):
	emit_signal("map_node_pressed", node)
