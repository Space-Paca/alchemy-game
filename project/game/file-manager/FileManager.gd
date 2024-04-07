extends Node

var dungeon = false
var continue_game = false
var difficulty_to_use = "normal"
var player_class = "alchemist"


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_profile()
		archive_file("user://profile.save", false)


func save_and_quit():
	save_game()
	archive_file("user://profile.save", false)
	get_tree().quit()


func save_game():
	save_profile()
	if current_run_exists():
		save_run()


func load_game():
	load_profile()


func load_profile():
	var profile_file = File.new()
	var dir = Directory.new()
	
	if profile_file.file_exists("user://profile.backup"):
		push_warning("Something went wrong with profile in a previous sessions, trying to fix it")
		if not profile_file.file_exists("user://profile.save"):
			push_warning("No original profile found")
			#If there isn't an official profile, just rename the backup
			dir.rename("user://profile.backup", "user://profile.save")
		else:
			var backup_data
			var err = profile_file.open("user://profile.backup", File.READ)
			if err != OK:
				push_error("Error trying to open debug profile whilst fixing errors:" + str(err))
			while profile_file.get_position() < profile_file.get_len():
				# Get the saved dictionary from the next line in the save file
				backup_data = parse_json(profile_file.get_line())
			profile_file.close()
			if backup_data.has("time"):
				var profile_data
				err = profile_file.open("user://profile.save", File.READ)
				if err != OK:
					push_error("Error trying to open original profile whilst fixing errors:" + str(err))
				while profile_file.get_position() < profile_file.get_len():
					# Get the saved dictionary from the next line in the save file
					profile_data = parse_json(profile_file.get_line())
				profile_file.close()
				if profile_data.has("time"):
					if Debug.compare_datetimes(backup_data.time, profile_data.time):
						push_warning("Backup data is more recent... using backup")
						archive_file("user://profile.save")
						dir.rename("user://profile.backup", "user://profile.save")
					else:
						push_warning("Original profile data is more recent... arquiving backup")
						archive_file("user://profile.backup")
						dir.remove("user://profile.backup")
				else:
					push_warning("Profile data has no time information... using backup")
					archive_file("user://profile.save")
					dir.rename("user://profile.backup", "user://profile.save")
			else:
				push_warning("Backup data has no time information... this shouldn't happen aaaah")
				archive_file("user://profile.backup")
				
		push_warning("Fixed it!")


	if not profile_file.file_exists("user://profile.save"):
		push_warning("Profile file not found. Starting a new profile file.")
		save_profile()
		
	var err = profile_file.open("user://profile.save", File.READ)
	if err != OK:
		push_error("Error trying to open profile whilst loading:" + str(err))
		
	while profile_file.get_position() < profile_file.get_len():
		# Get the saved dictionary from the next line in the save file
		var data = parse_json(profile_file.get_line())
		Profile.set_save_data(data)
		break
		
	profile_file.close()


func save_profile():
	var profile_data = Profile.get_save_data()
	
	#First save on a separate file as to avoid corruption
	var backup_file = File.new()
	var err = backup_file.open("user://profile.backup", File.WRITE)
	if err != OK:
		push_error("Error trying to open backup profile whilst saving:" + str(err))
	backup_file.store_line(to_json(profile_data))
	backup_file.close()
	
	#Now save directly on official profile.save
	var profile_file = File.new()
	err = profile_file.open("user://profile.save", File.WRITE)
	if err != OK:
		push_error("Error trying to open profile whilst saving:" + str(err))
	profile_file.store_line(to_json(profile_data))
	profile_file.close()
	
	#If reached here, everything should be okay, lets delete the backup
	var dir = Directory.new()
	err = dir.remove("user://profile.backup")
	if err != OK:
		push_error("Error trying to delete backup profile whilst saving:" + str(err))


func current_run_exists():
	return not not dungeon


func set_current_run(dungeon_ref):
	dungeon = dungeon_ref


func run_file_exists():
	var run_file = File.new()
	return run_file.file_exists("user://run.save")


func delete_run_file():
	create_run_backup()
	var run_file = File.new()
	if run_file.file_exists("user://run.save"):
		var dir = Directory.new()
		dir.remove("user://run.save")
	else:
		#Run file not found. Aborting deletion.
		return


func save_run():
	assert(dungeon, "Dungeon reference invalid.")
	create_run_backup()
	var run_file = File.new()
	var err = run_file.open("user://run.save", File.WRITE)
	if err != OK:
		push_error("Error trying to open run file whilst saving:" + str(err))
	var run_data = dungeon.get_save_data()
	run_file.store_line(to_json(run_data))
	run_file.close()


func create_run_backup():
	var run_file = File.new()
	if not run_file.file_exists("user://run.save"):
		return
	
	var err = run_file.open("user://run.save", File.READ)
	if err != OK:
		push_error("Error trying to open run file whilst creating backup:" + str(err))
	
	var backup_file = File.new()
	err = backup_file.open("user://run.backup", File.WRITE)
	if err != OK:
		push_error("Error trying to open backup run file:" + str(err))
	
	while run_file.get_position() < run_file.get_len():
		var data = parse_json(run_file.get_line())
		backup_file.store_line(to_json(data))
	run_file.close()
	backup_file.close()


func load_run():
	var run_file = File.new()
	if not run_file.file_exists("user://run.save"):
		push_error("Run file not found. Aborting load.")
		return
	var err = run_file.open("user://run.save", File.READ)
	if err != OK:
		push_error("Error trying to run file whilst loading:" + str(err))
	assert(dungeon, "Dungeon reference invalid.")
	while run_file.get_position() < run_file.get_len():
		var data = parse_json(run_file.get_line())
		dungeon.set_save_data(data)
		
	run_file.close()


func archive_file(path, use_warning := true):
	var dir = Directory.new()
	if not dir.dir_exists("user://archived_files"):
		push_warning("Making archived files directory")
		dir.make_dir("user://archived_files")
	var date = OS.get_datetime()
	var archive_filename = str(date.year) + "y_" + str(date.month) + "mo_" + str(date.day) + "d_" +\
						   str(date.hour) + "h_" + str(date.minute) + "mi_" + str(date.second) + "s_" +\
						   str(randi()%1000) + "_" + path.lstrip("user://")
	var err =  dir.copy(path, "user://archived_files/" + archive_filename)
	if err != OK:
		push_error("Error trying to duplicate file whilst archiving:" + str(err))
	
	if use_warning:
		push_warning("Archived file: " + str(archive_filename))
	else:
		print("Archived file: " + str(archive_filename))
