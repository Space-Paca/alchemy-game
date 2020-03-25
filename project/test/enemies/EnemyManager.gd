extends Node

const ENEMY_DB = {"skeleton": "res://database/enemies/Skeleton.gd"}
const ENEMY = preload("res://test/enemies/Enemy.tscn")

func create_object(enemy_type):
	
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist")
		assert(false)
	
	var enemy_data = load(ENEMY_DB[enemy_type]).new()
	
	var enemy = ENEMY.instance()
	enemy.type = enemy_type
	enemy.set_image(load(enemy_data.image))
	enemy.set_max_hp(enemy_data.hp)
	return enemy

func get_data(enemy_type):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist")
		assert(false)
	
	return load(ENEMY_DB[enemy_type])
