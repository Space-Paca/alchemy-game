extends Node


func save():
	#Save configurations
	var profile_file = File.new()
	profile_file.open("user://profile.save", File.WRITE)
	var profile_data = Profile.get_save_data()
	profile_file.store_line(to_json(profile_data))
	profile_file.close()
