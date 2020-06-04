extends Node

const ENEMY_DB = {
				  "humunculus": "res://database/enemies/Homunculus.gd",
				  "spawner_humunculus": "res://database/enemies/SpawnerHomunculus.gd",
				  "tank": "res://database/enemies/TankHomunculus.gd",
				  "baby_humunculus": "res://database/enemies/BabyHomunculus.gd",
				  "big_buffer": "res://database/enemies/BigBuffer.gd",
				  "delayed_hitter": "res://database/enemies/DelayedHitter.gd",
				  "dodge": "res://database/enemies/DodgeEnemy.gd",
				  "poison": "res://database/enemies/Poisunculus.gd",
				  "baby_poison": "res://database/enemies/BabyPoisunculus.gd",
				  "baby_slasher": "res://database/enemies/BabySlasher.gd",
				  "elite_dodger" : "res://database/enemies/EliteDodger.gd",
				  "boss_1" : "res://database/enemies/Boss1.gd",
				}
const ENEMY = preload("res://game/enemies/Enemy.tscn")


func create_object(enemy_type, player):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist: " + str(enemy_type))
		assert(false)
	
	var enemy_data = load(ENEMY_DB[enemy_type]).new()
	
	var enemy = ENEMY.instance()
	
	#Duplicate material so shader parameters only affect this object
	var mat_override = enemy.get_node("Sprite").get_material().duplicate()
	enemy.get_node("Sprite").set_material(mat_override)
	
	# Highlight texture
	var highlight = load(enemy_data.image.replace("idle.png", "highlight.png"))
	
	enemy.init(enemy_data.name, enemy_data.hp)
	var logic = {"states":enemy_data.states,
				 "connections": enemy_data.connections,
				 "first_state": enemy_data.first_state,
				}
	enemy_data.set_node_references(enemy, player)
	enemy.setup(logic, load(enemy_data.image), highlight, enemy_data)
	return enemy


func get_data(enemy_type):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist: " + str(enemy_type))
		assert(false)
	
	return load(ENEMY_DB[enemy_type])
