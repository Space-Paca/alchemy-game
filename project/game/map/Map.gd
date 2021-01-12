extends Control
class_name Map

signal map_node_pressed(node)

onready var bg = $Background
onready var lines = $Lines
onready var camera = $Camera
onready var click_block = $ClickBlock
onready var nodes = $Nodes
onready var floor_label = $CanvasLayer/FloorLabel

const MAP_NODE_SCENE = preload("res://game/map/MapNode.tscn")
const MAP_LINE = preload("res://game/map/MapLine.tscn")
const CAMERA_LINEAR_SPEED = 60
const CAMERA_EXPONENTIAL_SPEED = .1
const EPSLON = 1
const CENTRAL_NODE_CHILDREN_SIZE = 2
const PLAYER_UI_HEIGHT = 250

var active_paths := 0
var active_nodes := []
var initial_node : MapNode
var current_level : int setget set_level
var update_camera := true
var camera_last_pos = false
var stored_map_positions = null
var positions = null
var center_position = null
var player = null


func _ready():
	duplicate_stored_positions()


func duplicate_stored_positions():
	stored_map_positions = $FixedPositions.duplicate(7)


func _process(dt):
	if update_camera:
		#Get camera target pos
		var target_pos = get_screen_center()
		if active_nodes.size() > 0:
			var margin = 20
			var left = 9999
			var right = -9999
			var top = 9999
			var bottom = -9999
			for node in active_nodes:
				if node.rect_position.x < left:
					left = node.rect_position.x
				if node.rect_position.x > right:
					right = node.rect_position.x
				if node.rect_position.y < top:
					top = node.rect_position.y
				if node.rect_position.y > bottom:
					bottom = node.rect_position.y
			left -= margin
			right += margin
			top -= margin
			bottom += margin
			target_pos = Vector2(left+(right-left)/2, top+(bottom-top)/2)
			target_pos += get_screen_center()
# warning-ignore:integer_division
		target_pos.y -= PLAYER_UI_HEIGHT/2

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
	enable_tooltips()
	floor_label.show()
	update_camera = true
	if camera_last_pos:
		camera.position = camera_last_pos


func disable():
	hide()
	disable_tooltips()
	floor_label.hide()
	update_camera = false
	camera_last_pos = camera.position
	reset_camera()

func enable_tooltips():
	for node in $Nodes.get_children():
		if node.is_revealed:
			node.enable_tooltips()

func disable_tooltips():
	for node in $Nodes.get_children():
		if node.is_revealed:
			node.disable_tooltips()


func recipe_toogle(active : bool):
	if not visible:
		return
	
	floor_label.visible = !active
	if active:
		disable_tooltips()
	else:
		enable_tooltips()


func set_level(level:int):
	current_level = level
	floor_label.text = str("Floor ", current_level)


func shift_positions():
	if randf() > .5:
		positions.rect_scale.x = -1
	if randf() > .5:
		positions.rect_rotation = 180
	
	positions.rect_rotation += 5 * (randf() * 2 - 1)


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


func reset_camera(is_map := false):
	$Camera.position = get_screen_center() 
	if is_map:
# warning-ignore:integer_division
		$Camera.position -= Vector2(0, PLAYER_UI_HEIGHT/2)


func set_player(_player):
	player = _player


func create_map(normal_encounters:int, elite_encounters:int, smiths:int=1,
		rests:int=2, shops:int=1, events:int=0, labs:int=1, treasures:int=1):
	
	#Reset Stored Positions
	var old_positions = get_node("FixedPositions")
	if old_positions:
		remove_child(old_positions)
		old_positions.queue_free()
	
	reset_camera(true)
	camera_last_pos = false
	
	var untyped_nodes : Array
	var node_distance : Dictionary
	while true:
		var map_valid = true
		
		randomize()
		positions = stored_map_positions.duplicate(7)
		center_position = positions.get_node("Center")
		#Reduce randomly number of childs center node has
		center_position.children.shuffle()
		while center_position.children.size() > CENTRAL_NODE_CHILDREN_SIZE:
			center_position.children.remove(1)
		
		add_child_below_node(nodes, positions)
		
		active_nodes = []
		
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
		untyped_nodes = []
		node_distance = {initial_node: 0}
		while total_nodes:
			if available_starting_positions.empty():
				map_valid = false
				break
			
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
			else:
				# Remove all remaining children except one, so we can only use at max 2 or 3 children
				# from this node
				var max_children = 1 if randf() > .7 else 2	
				while starting_pos.children.size() > max_children:
					starting_pos.children.remove(0)
			
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
			new_node.disable_tooltips()
			new_node.modulate.a = 0
			new_node.set_camera($Camera)
			nodes.add_child(new_node)
			new_node.rect_global_position = new_pos.global_position
			new_pos.node = new_node
			starting_pos.node.is_leaf = false
			starting_pos.node.map_tree_children.append(new_node)
	# warning-ignore:return_value_discarded
			new_node.connect("pressed", self, "_on_map_node_clicked", [new_node])
			
			#Update distance to this new position
			node_distance[new_node] = node_distance[starting_pos.node] + 1
			
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
		if map_valid:
			break
		else:
			print("Couldn't create a valid map. Trying again...")
			continue
	
	#If reached here, properly selected one node for every room needed
	
	### TYPING NODES ###
	untyped_nodes.shuffle()
	
	#Setting up boss, on the farthest node from center
	var farthest_node = null
	var distance = -1
	for node in untyped_nodes:
		if node_distance[node] > distance:
			distance = node_distance[node]
			farthest_node = node
	farthest_node.set_type(MapNode.BOSS)
	untyped_nodes.erase(farthest_node)
	
	#Setting up elite encounters
	var to_erase = []
	for node in untyped_nodes:
		var map_node : MapNode = node
		if map_node.is_leaf and elite_encounters > 0:
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


func reveal_all_paths():
	for node in active_nodes:
		reveal_paths(node)


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
	node.enable_tooltips()
	if node.should_autoreveal() or\
	   Debug.reveal_map or\
	   (player and player.has_artifact("reveal_map")):
		reveal_paths(node)
	
	active_paths -= 1
	
	if not active_paths:
		set_disabled(false)


func _on_map_node_clicked(node:MapNode):
	emit_signal("map_node_pressed", node)
