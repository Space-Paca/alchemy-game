extends Node

const ENEMY_DB = {"skeleton": "res://database/enemies/Skeleton.gd"}
const ENEMY = preload("res://game/enemies/Enemy.tscn")


func create_object(enemy_type):
	
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist")
		assert(false)
	
	var enemy_data = load(ENEMY_DB[enemy_type]).new()
	
	var enemy = ENEMY.instance()
	enemy.init(enemy_data.name, enemy_data.hp)
	var logic = {"states":enemy_data.states,
				 "connections": enemy_data.connections,
				 "first_state": enemy_data.first_state,
				}
	enemy_data.set_enemy_reference(enemy)
	enemy.setup(logic, load(enemy_data.image), enemy_data)
	return enemy


func get_data(enemy_type):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist")
		assert(false)
	
	return load(ENEMY_DB[enemy_type])