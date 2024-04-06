extends Node


func check_for_all():
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
	
	#Progression
	if Profile.is_max_level("recipes"):
		Steam.set_achievement("max_prog_recipes")
	if Profile.is_max_level("artifacts"):
		Steam.set_achievement("max_prog_artifacts")
	if Profile.is_max_level("misc"):
		Steam.set_achievement("max_prog_misc")
	
	
	#Other
	if stats.gameover > 0:
		Steam.set_achievement("died_once")
