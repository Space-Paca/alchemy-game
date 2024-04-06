extends Node

#Killing this enemies gives out an achievement
const ELITE_ENEMIES = [
	"restrainer","confuser","undead_morkh","freezer","timing_bomber",
	"elite_dodger","poison"
]


func check_for_all():
	if not Debug.is_steam:
		return
	
	var stats = Profile.stats
	#Finished game
	for character_name in stats.times_finished.keys():
		var character = stats.times_finished[character_name]
		var done = false
		if character.easy > 0:
			done = true
			Steam.set_achievement("finished_easy")
		if character.normal > 0:
			done = true
			Steam.set_achievement("finished_easy")
			Steam.set_achievement("finished_normal")
		if character.hard > 0:
			done = true
			Steam.set_achievement("finished_easy")
			Steam.set_achievement("finished_normal")
			Steam.set_achievement("finished_hard")
		if done:
			Steam.set_achievement("finished_"+str(character_name))
			Steam.set_achievement("reached_floor2")
			Steam.set_achievement("reached_floor3")
	
	#Progression
	if Profile.is_max_level("recipes"):
		Steam.set_achievement("max_prog_recipes")
	if Profile.is_max_level("artifacts"):
		Steam.set_achievement("max_prog_artifacts")
	if Profile.is_max_level("misc"):
		Steam.set_achievement("max_prog_misc")
	
	#Compendium
	var saw_all = true
	var memorized_all = true
	var memorized_one = false
	for recipe_id in Profile.known_recipes.keys():
		var level = Profile.get_recipe_memorized_level(recipe_id)
		if level < Profile.MAX_MEMORIZATION_LEVEL:
			memorized_all = false
		else:
			memorized_one = true
		if Profile.known_recipes[recipe_id].amount < 1:
			saw_all = false
	if saw_all:
		Steam.set_achievement("compendium_complete")
	if memorized_all:
		Steam.set_achievement("compendium_memorized")
	if memorized_one:
		Steam.set_achievement("recipe_memorized")
	
	#Other
	if stats.gameover > 0:
		Steam.set_achievement("died_once")


func unlock(ach_name):
	if not Debug.is_steam:
		return
	Steam.set_achievement("ach_name")


func check_enemy_achievement(enemy_type):
	if ELITE_ENEMIES.has(enemy_type):
		Steam.set_achievement("enemy_defeated_"+str(enemy_type))
