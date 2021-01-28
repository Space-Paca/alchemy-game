extends Node

func save_and_quit():
	save_game()
	get_tree().quit()


func save_game():
	save_profile()


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
