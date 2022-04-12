extends Node2D

onready var shield := $Shield
onready var shard_parent := $ShardParent

const SHARD_LIN_VEL := 150.0
const SHARD_ANG_VEL := .1
const SHARD_DAMP := 4.0

var shard_velocity_map := {}


func explode_shield():
	var points = shield.polygon
	var shield_center : Vector2 = shield.texture.get_size() / 2
	shard_parent.position -= shield_center
	
	# Add more points
	for i in points.size():
		if i % 4:
			continue
		var new_point : Vector2 = lerp(points[i],
				points[(i+points.size()/2)%points.size()], rand_range(.2, .8))
		points.append(new_point)
	
	var delaunay_points = Geometry.triangulate_delaunay_2d(points)
	
	assert(delaunay_points, "no delaunay points found for some reason")
	
	# loop over each triangle
	for i in delaunay_points.size() / 3:
		var shard_pool := PoolVector2Array()
		var center := Vector2()
		
		# loop over the three triangle points
		for n in 3:
			shard_pool.append(points[delaunay_points[(i *3) + n]])
			center += points[delaunay_points[(i *3) + n]] / 3
		
		var shard := Polygon2D.new()
		shard.polygon = shard_pool
		shard.texture = shield.texture
		
		shard_velocity_map[shard] = (shield_center - center).normalized()
		shard_velocity_map[shard].x *= rand_range(.5, 1)
		shard_velocity_map[shard].y *= rand_range(.5, 1)
		
		shard_parent.add_child(shard)


func _process(delta):
	for shard in shard_velocity_map.keys():
		shard.position -= shard_velocity_map[shard] * delta * SHARD_LIN_VEL
		shard.rotation -= shard_velocity_map[shard].x * delta * SHARD_ANG_VEL
		shard_velocity_map[shard] -= shard_velocity_map[shard] * delta * SHARD_DAMP
		
