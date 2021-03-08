extends Node

var dungeon = false
var continue_game = false


func save_and_quit():
	save_game()
	get_tree().quit()


func save_game():
	save_profile()
	if current_run_exists():
		save_run()


func load_game():
	load_profile()


func load_profile():
	var profile_file = File.new()
	if not profile_file.file_exists("user://profile.save"):
		print("Profile file not found. Starting a new profile file.")
		save_profile()
		return
		
	profile_file.open("user://profile.save", File.READ)
	while profile_file.get_position() < profile_file.get_len():
		# Get the saved dictionary from the next line in the save file
		var data = parse_json(profile_file.get_line())
		Profile.set_save_data(data)
		
	profile_file.close()


func save_profile():
	var profile_file = File.new()
	profile_file.open("user://profile.save", File.WRITE)
	var profile_data = Profile.get_save_data()
	profile_file.store_line(to_json(profile_data))
	profile_file.close()


func current_run_exists():
	return not not dungeon


func set_current_run(dungeon_ref):
	dungeon = dungeon_ref


func run_file_exists():
	var run_file = File.new()
	return run_file.file_exists("user://run.save")


func delete_run_file():
	var run_file = File.new()
	if run_file.file_exists("user://run.save"):
		var dir = Directory.new()
		dir.remove("user://run.save")
	else:
		print("Run file not found. Aborting deletion.")
		return


func save_run():
	assert(dungeon, "Dungeon reference invalid.")
	
	var run_file = File.new()
	run_file.open("user://run.save", File.WRITE)
	var run_data = dungeon.get_save_data()
	run_file.store_line(to_json(run_data))
	run_file.close()


func load_run():
	var run_file = File.new()
	if not run_file.file_exists("user://run.save"):
		print("Run file not found. Aborting load.")
		return
	run_file.open("user://run.save", File.READ)
	assert(dungeon, "Dungeon reference invalid.")
	while run_file.get_position() < run_file.get_len():
		var data = parse_json(run_file.get_line())
		dungeon.set_save_data(data)
		
	run_file.close()
	
	
	

