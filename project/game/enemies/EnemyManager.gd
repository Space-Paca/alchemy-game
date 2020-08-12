extends Node

const ENEMY_DB = {
				  "humunculus": preload("res://database/enemies/Homunculus.gd"),
				  "spawner_humunculus": preload("res://database/enemies/SpawnerHomunculus.gd"),
				  "baby_humunculus": preload("res://database/enemies/BabyHomunculus.gd"),
				  "baby_humunculus_plus": preload("res://database/enemies/BabyHomunculusPlus.gd"),
				  "big_buffer": preload("res://database/enemies/BigBuffer.gd"),
				  "delayed_hitter": preload("res://database/enemies/DelayedHitter.gd"),
				  "delayed_hitter_plus": preload("res://database/enemies/DelayedHitterPlus.gd"),
				  "dodge": preload("res://database/enemies/DodgeEnemy.gd"),
				  "poison": preload("res://database/enemies/Poisunculus.gd"),
				  "baby_poison": preload("res://database/enemies/BabyPoisunculus.gd"),
				  "baby_slasher": preload("res://database/enemies/BabySlasher.gd"),
				  "baby_retaliate": preload("res://database/enemies/BabyRetaliate.gd"),
				  "big_divider" : preload("res://database/enemies/BigDivider.gd"),
				  "medium_divider" : preload("res://database/enemies/MediumDivider.gd"),
				  "small_divider" : preload("res://database/enemies/SmallDivider.gd"),
				  "revenger" : preload("res://database/enemies/Revenger.gd"),
				  "martyr" : preload("res://database/enemies/Martyr.gd"),
				  "rager" : preload("res://database/enemies/Rager.gd"),
				  "curser" : preload("res://database/enemies/Curser.gd"),
				  "parasiter" : preload("res://database/enemies/Parasiter.gd"),
				  "timing_bomber" : preload("res://database/enemies/TimingBomber.gd"),
				  "elite_dodger" : preload("res://database/enemies/EliteDodger.gd"),
				  "freezer" : preload("res://database/enemies/Freezer.gd"),
				  "self_destructor" : preload("res://database/enemies/SelfDestructor.gd"),
				  "boss_1" : preload("res://database/enemies/Boss1.gd"),
				  "boss_2" : preload("res://database/enemies/Boss2.gd"),
				}
const ENEMY = preload("res://game/enemies/Enemy.tscn")

func create_object(enemy_type):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist: " + str(enemy_type))
		assert(false)
	
	var enemy_data = ENEMY_DB[enemy_type].new()
	
	var enemy = ENEMY.instance()
	
	#Duplicate material so shader parameters only affect this object
	var mat_override = enemy.get_node("Sprite").get_material().duplicate()
	enemy.get_node("Sprite").set_material(mat_override)
	
	enemy.init(enemy_data.name, enemy_data.hp)
	var logic = {"states":enemy_data.states,
				 "connections": enemy_data.connections,
				 "first_state": enemy_data.first_state,
				}

	enemy.setup(logic, load(enemy_data.image), enemy_data)
	return enemy


func get_data(enemy_type):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist: " + str(enemy_type))
		assert(false)
	
	return ENEMY_DB[enemy_type]
