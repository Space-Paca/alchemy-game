extends Node

#Filter
const AUDIO_FILTER = preload("res://game/pause/pause_audio_filter.tres")
#Amplify
const AMPLIFY_EFFECT = preload("res://game/pause/audio_amplify.tres")
const MAX_AMPLIFY = 6 #Amplify effect when player is in extreme danger
const MIN_AMPLIFY = 0 #Value to remove effect
const AMPLIFY_SPEED = 10 #Speed to increase or decrease amplify effect
#Cutoff
const CUTOFF_SPEED = 15000 #Speed to change between cutoffs
const MAX_CUTOFF = 20500 #Cutoff when player is > 50hp (aka no effect)
const DANGER_CUTOFF = 10000 #Cutoff when player is < 50hp
const EXTREME_DANGER_CUTOFF = 2000 #Cutoff when player is < 20hp
#Bus
enum {MASTER_BUS, BGM_BUS, SFX_BUS}
#Fade
const FADEOUT_SPEED = 20 #Speed bgms fadeout
const FADEIN_SPEED = 60 #Speed bgms fadein
const TRACK_FADEOUT_SPEED = 20 #Speed individual bgm tracks fadein
const TRACK_FADEIN_SPEED = 60 #Speed individual bgm tracks fadeout
const AUX_FADEOUT_SPEED = 40 #Speed aux bgm fadein
const AUX_FADEIN_SPEED = 60 #Speed aux bgm fadeout
#Volume
const MUTE_DB = -80 #Muted volume
const CONTROL_MULTIPLIER = 2.5
#Layer
const MAX_LAYERS = 3
#BGM
const BGM_PATH = "res://database/audio/bgms/"
onready var BGMS = {}
#AUX
onready var AUX_BGMS = ["","",""]
const AMBIENCE_VARIATIONS = 3
const AMBIENCE_NAME_MAP = ["forest", "cave", "dungeon"]
#SFX
const MAX_SFXS = 100
const SFX_PATH = "res://database/audio/sfxs/"
const MIN_DUPLICATE_INTERVAL = .08 #Minimum time needed to play same sfx again
onready var SFXS = {}
onready var CUR_IDLE_SFX = {}
#LOCS
const LOC_PATH = "res://database/audio/locs/"
onready var LOCS = {}

var last_ambience_bgm_idx = false
var bgms_last_pos = {}
var just_played_sfxs = {}
var just_played_variations = {}
var cur_bgm = null
var cur_aux_bgm = null
var using_layers = false
var cur_sfx_player := 0
var bgm_filter_enabled = false


func _ready():
	setup_nodes()
	setup_bgms()
	setup_sfxs()
	setup_locs()


func _process(dt):
	for sfx_name in just_played_sfxs.keys():
		just_played_sfxs[sfx_name] -= dt
		if just_played_sfxs[sfx_name] <= 0.0:
			just_played_sfxs.erase(sfx_name)

# Setups

func setup_nodes():
	for _i in range(MAX_SFXS + 1):
		var node = AudioStreamPlayer.new()
		node.stream = AudioStreamRandomPitch.new()
		node.stream.random_pitch = 1.0
		node.bus = "SFX"
		$SFXS.add_child(node)


func setup_bgms():
	var dir = Directory.new()
	if dir.open(BGM_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				BGMS[file_name.replace(".tres", "")] = load(BGM_PATH + file_name)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access bgms path.")
		assert(false)


func setup_sfxs():
	var dir = Directory.new()
	if dir.open(SFX_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name != "." and file_name != "..":
				SFXS[file_name.replace(".tres", "")] = load(SFX_PATH + file_name)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access sfxs path.")
		assert(false)


func setup_locs():
	var dir = Directory.new()
	if dir.open(LOC_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var enemy_regex = RegEx.new()
		enemy_regex.compile("([a-zA-Z0-9_\\-]+)_(\\w+).tres")
		var type_regex = RegEx.new()
		type_regex.compile("(\\w+)(\\d+)")
		while file_name != "":
			if not dir.current_is_dir() and file_name != "." and file_name != "..":
				var result = enemy_regex.search(file_name)
				#Found enemy loc, first parse name, then create data on memory
				if result:
					var name = result.get_string(1)
					var type = result.get_string(2)
					if not LOCS.has(name):
						LOCS[name] = {} 
					result = type_regex.search(type)
					#Found a variation of type
					if result:
						type = result.get_string(1)
						if not LOCS[name].has(type):
							LOCS[name][type] = []
						LOCS[name][type].append(load(LOC_PATH + file_name))
					else:
						LOCS[name][type] = load(LOC_PATH + file_name)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access locutions path.")
		assert(false)


# Debug Methods


func change_group_of_loc(name_contains_this_string, type_contains_this_string, attribute_to_change, value):
	for name_key in LOCS.keys():
		if name_contains_this_string == "" or name_key.find(name_contains_this_string) != -1:
			for type_key in LOCS[name_key].keys():
				if type_contains_this_string == "" or type_key.find(type_contains_this_string) != -1:
					var tres = LOCS[name_key][type_key]
					var path = LOC_PATH + name_key + "_" + type_key + ".tres"
					change_tres(tres, path, attribute_to_change, value)


func change_group_of_bgm(contains_this_string, attribute_to_change, value):
	for key in BGMS.keys():
		var tres = BGMS[key]
		var path = BGM_PATH + key + ".tres"
		if contains_this_string == "" or key.find(contains_this_string) != -1:
			change_tres(tres, path, attribute_to_change, value)


func change_group_of_sfx(contains_this_string, attribute_to_change, value):
	for key in SFXS.keys():
		var tres = SFXS[key]
		var path = SFX_PATH + key + ".tres"
		if contains_this_string == "" or key.find(contains_this_string) != -1:
			change_tres(tres, path, attribute_to_change, value)


func change_tres(tres, path, attribute_to_change, value):
	assert(tres.get(attribute_to_change) != null, "Resource doesn't have this attribute:" + str(attribute_to_change))
	tres[attribute_to_change] = value
	var err = ResourceSaver.save(path, tres)
	assert(err == OK, "Couldn't save resource:" + str(path)) 
	printt("Saving resource: ", path, attribute_to_change, value)

# Bus Methods

#Expects a value between 0 and 1
func set_bus_volume(which_bus: int, value: float):
	var db
	if value <= 0.0:
		db = MUTE_DB
	else:
		db = (1-value)*MUTE_DB/CONTROL_MULTIPLIER
	
	if which_bus in [MASTER_BUS, BGM_BUS, SFX_BUS]:
		AudioServer.set_bus_volume_db(which_bus, db)
	else:
		assert(false, "Not a valid bus to set volume: " + str(which_bus))


func get_bus_volume(which_bus: int):
	if which_bus in [MASTER_BUS, SFX_BUS, BGM_BUS]:
		return clamp(1.0 - AudioServer.get_bus_volume_db(which_bus)/float(MUTE_DB/CONTROL_MULTIPLIER), 0.0, 1.0)
	else:
		assert(false, "Not a valid bus to set volume: " + str(which_bus))


# BGM Methods

func get_bgm_last_pos(name):
	if not bgms_last_pos.has(name):
		bgms_last_pos[name] = 0
	return bgms_last_pos[name]


func set_bgm_last_pos(name, pos):
	bgms_last_pos[name] = pos


func enable_bgm_filter_effect(target_db = -17, speed_mod = 1.0, id = null):
	if bgm_filter_enabled:
		bgm_filter_enabled = id if id else true
		return
	bgm_filter_enabled = id if id else true

	$BGMBusEffectTween.stop_all()
	#Assumes no other effect is possible
	if AudioServer.get_bus_effect_count(1) == 3:
		AudioServer.remove_bus_effect(1, 2)
	AudioServer.add_bus_effect(1, AMPLIFY_EFFECT)
	var dur = abs(AMPLIFY_EFFECT.volume_db - target_db)/(15*speed_mod)
	$BGMBusEffectTween.interpolate_property(AMPLIFY_EFFECT, "volume_db", AMPLIFY_EFFECT.volume_db, target_db, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$BGMBusEffectTween.start()

func disable_bgm_filter_effect(speed_mod = 1.0, id = null):
	if not bgm_filter_enabled or (id and id != bgm_filter_enabled):
		return
	bgm_filter_enabled = false

	$BGMBusEffectTween.stop_all()
	#Assumes no other effect has entered
	var dur = abs(AMPLIFY_EFFECT.volume_db)/(20*speed_mod)
	$BGMBusEffectTween.interpolate_property(AMPLIFY_EFFECT, "volume_db", AMPLIFY_EFFECT.volume_db, 0, dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$BGMBusEffectTween.start()
	
	yield($BGMBusEffectTween, "tween_completed")

	if not bgm_filter_enabled and AudioServer.get_bus_effect_count(1) == 3:
		AudioServer.remove_bus_effect(1, 2)


func get_bgm_layer(name, layer):
	return BGMS[name + "-l" + str(layer)]


func lower_bgm_volume():
	#Regular BGMs
	if not using_layers:
		var db = BGMS[cur_bgm].lowered_db
		var duration = abs(db - $BGMPlayer1.volume_db)/float(FADEOUT_SPEED)
		$Tween.remove($BGMPlayer1, "volume_db")
		$Tween.interpolate_property($BGMPlayer1, "volume_db", $BGMPlayer1.volume_db, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	else:
		for i in range(1, using_layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			var db = get_bgm_layer(cur_bgm, i).lowered_db
			var duration = abs(db - player.volume_db)/float(FADEOUT_SPEED)
			$Tween.remove(player, "volume_db")
			$Tween.interpolate_property(player, "volume_db", player.volume_db, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	#Aux BGMs
	var i = 1
	for aux_bgm in AUX_BGMS:
		if aux_bgm != "":
			var db = BGMS[aux_bgm].lowered_db
			var player = get_node("AuxBGMPlayer" + str(i))
			var duration = abs(db - player.volume_db)/float(FADEOUT_SPEED)
			$AuxTween.remove(player, "volume_db")
			$AuxTween.interpolate_property(player, "volume_db", player.volume_db, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$AuxTween.start()
			break
		i += 1


func resume_bgm_volume():
	#Regular BGMs
	if not using_layers:
		var db = BGMS[cur_bgm].base_db
		var duration = abs(db - $BGMPlayer1.volume_db)/float(FADEIN_SPEED)
		$Tween.remove($BGMPlayer1, "volume_db")
		$Tween.interpolate_property($BGMPlayer1, "volume_db", $BGMPlayer1.volume_db, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	else:
		for i in range(1, using_layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			var db = get_bgm_layer(cur_bgm, i).base_db
			var duration = abs(db - player.volume_db)/float(FADEIN_SPEED)
			$Tween.remove(player, "volume_db")
			$Tween.interpolate_property(player, "volume_db", player.volume_db, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	#Aux BGMs
	var i = 1
	for aux_bgm in AUX_BGMS:
		if aux_bgm != "":
			var db = BGMS[aux_bgm].base_db
			var player = get_node("AuxBGMPlayer" + str(i))
			var duration = abs(db - player.volume_db)/float(FADEIN_SPEED)
			$AuxTween.remove(player, "volume_db")
			$AuxTween.interpolate_property(player, "volume_db", player.volume_db, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$AuxTween.start()
			break
		i += 1


func play_bgm(name, layers = false, start_from_beginning = false):
	if Debug.seasonal_event:
		var season_name
		if not layers:
			season_name = Debug.seasonal_event + "_" + name
		else:
			season_name = Debug.seasonal_event + "_" + name + "-l" + str(layers)
		if BGMS.has(season_name):
			name = season_name
		
	if not layers:
		assert(BGMS[name])
	else:
		assert(get_bgm_layer(name, layers))
	
	if cur_bgm:
		stop_bgm()
	
	cur_bgm = name
	using_layers = layers
	
	if not using_layers:
		$BGMPlayer1.stream = BGMS[name].asset
		$BGMPlayer1.volume_db = MUTE_DB
		if start_from_beginning:
			$BGMPlayer1.play(0)
		else:
			$BGMPlayer1.play(get_bgm_last_pos(name))
		var duration = (BGMS[name].base_db - MUTE_DB)/float(FADEIN_SPEED)
		$Tween.remove($BGMPlayer1, "volume_db")
		$Tween.interpolate_property($BGMPlayer1, "volume_db", MUTE_DB, BGMS[name].base_db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()
	else:
		for i in range(1, layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			var layer = get_bgm_layer(name, i)
			player.stream = layer.asset
			player.volume_db = MUTE_DB
			if start_from_beginning:
				player.play(0)
			else:
				player.play(get_bgm_last_pos(name))
			var duration = (layer.base_db - MUTE_DB)/float(FADEIN_SPEED)
			$Tween.remove(player, "volume_db")
			$Tween.interpolate_property(player, "volume_db", MUTE_DB, layer.base_db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()


func stop_bgm(speed_mod := 1.0, stop_aux_bgm := true):
	if stop_aux_bgm:
		stop_all_aux_bgm()
	remove_bgm_effect()
	for i in range(1, MAX_LAYERS + 1):
		var fadein = get_node("BGMPlayer"+str(i))
		if fadein.is_playing():
			var fadeout = get_node("FadeOutBGMPlayer"+str(i))
			var pos = fadein.get_playback_position()
			set_bgm_last_pos(cur_bgm, pos)
			var vol = fadein.volume_db
			fadein.stop()
			fadeout.stop()
			fadeout.volume_db = vol
			fadeout.stream = fadein.stream
			fadeout.play(pos)
			var duration = (vol - MUTE_DB)/FADEOUT_SPEED
			duration /= speed_mod
			$Tween.remove(fadeout, "volume_db")
			$Tween.interpolate_property(fadeout, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()


func update_bgm_layers(layers_array: Array):
	for idx in range(0, layers_array.size()):
		if layers_array[idx]:
			play_bgm_layer(idx + 1)
		else:
			stop_bgm_layer(idx + 1)


func stop_bgm_layer(layer: int):
	var player = get_node("BGMPlayer"+str(layer))
	var vol = player.volume_db
	var duration = (vol - MUTE_DB)/float(TRACK_FADEOUT_SPEED)
	$Tween.remove(player, "volume_db")
	$Tween.interpolate_property(player, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()


func play_bgm_layer(layer: int):
	var player = get_node("BGMPlayer"+str(layer))
	$Tween.remove(player, "volume_db")
	var vol = player.volume_db
	var db = get_bgm_layer(cur_bgm, layer).base_db
	var duration = (db - vol)/float(TRACK_FADEIN_SPEED)
	$Tween.remove(player, "volume_db")
	$Tween.interpolate_property(player, "volume_db", vol, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()


func remove_bgm_effect():
	#remove filter
	if AudioServer.is_bus_effect_enabled(BGM_BUS, 0):
		var effect = AudioServer.get_bus_effect(BGM_BUS, 0)
		var duration = abs(MAX_CUTOFF - effect.cutoff_hz)/CUTOFF_SPEED
		$BusEffectTween.remove(effect, "cutoff_hz")
		$BusEffectTween.interpolate_property(effect, "cutoff_hz", effect.cutoff_hz, MAX_CUTOFF, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
		yield($BusEffectTween, "tween_completed")
		AudioServer.set_bus_effect_enabled(BGM_BUS, 0, false)
	#remove amplify	
	var effect = AudioServer.get_bus_effect(BGM_BUS, 1)
	var duration = abs(MIN_AMPLIFY - effect.volume_db)/AMPLIFY_SPEED
	$BusEffectTween.remove(effect, "volume_db")
	$BusEffectTween.interpolate_property(effect, "volume_db", effect.volume_db, MIN_AMPLIFY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$BusEffectTween.start()


func start_bgm_effect(type: String):
	if type == "danger":
		#filter
		var effect = AudioServer.get_bus_effect(BGM_BUS, 0)
		var duration = abs(DANGER_CUTOFF - effect.cutoff_hz)/CUTOFF_SPEED
		AudioServer.set_bus_effect_enabled(BGM_BUS, 0, true)
		$BusEffectTween.remove(effect, "cutoff_hz")
		$BusEffectTween.interpolate_property(effect, "cutoff_hz", effect.cutoff_hz, DANGER_CUTOFF, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
		
		#remove amplify
		effect = AudioServer.get_bus_effect(BGM_BUS, 1)
		duration = abs(MIN_AMPLIFY - effect.volume_db)/AMPLIFY_SPEED
		$BusEffectTween.remove(effect, "volume_db")
		$BusEffectTween.interpolate_property(effect, "volume_db", effect.volume_db, MIN_AMPLIFY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
	if type == "extreme-danger":
		#filter
		var effect = AudioServer.get_bus_effect(BGM_BUS, 0)
		var duration = abs(EXTREME_DANGER_CUTOFF - effect.cutoff_hz)/CUTOFF_SPEED
		AudioServer.set_bus_effect_enabled(BGM_BUS, 0, true)
		$BusEffectTween.remove(effect, "cutoff_hz")
		$BusEffectTween.interpolate_property(effect, "cutoff_hz", effect.cutoff_hz, EXTREME_DANGER_CUTOFF, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
		
		#amplify
		effect = AudioServer.get_bus_effect(BGM_BUS, 1)
		duration = abs(MAX_AMPLIFY - effect.volume_db)/AMPLIFY_SPEED
		$BusEffectTween.remove(effect, "volume_db")
		$BusEffectTween.interpolate_property(effect, "volume_db", effect.volume_db, MAX_AMPLIFY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()


# Aux BGM Methods

func play_aux_bgm(name: String):
	var free_slot = false
	var i = 1
	for aux_bgm in AUX_BGMS:
		if aux_bgm == name:
			return
		if aux_bgm == "":
			free_slot = i
			break
		i += 1
	if not free_slot:
		push_error("Don't have a free slot for aux bgm: " + str(name))
		assert(false)
	
	AUX_BGMS[i-1] = name
	
	var player = get_node("AuxBGMPlayer" + str(i))
	player.stream = BGMS[name].asset
	player.volume_db = MUTE_DB
	player.play()
	var db = BGMS[name].base_db
	var duration = abs(db - MUTE_DB)/float(AUX_FADEIN_SPEED*2)
	$AuxTween.remove(player, "volume_db")
	$AuxTween.interpolate_property(player, "volume_db", MUTE_DB, db, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$AuxTween.start()	


func stop_all_aux_bgm():
	for aux_bgm in AUX_BGMS:
		if aux_bgm != "":
			stop_aux_bgm(aux_bgm)


func stop_aux_bgm(name):
	var i = 1
	for aux_bgm in AUX_BGMS:
		if aux_bgm == name:
			var fadein = get_node("AuxBGMPlayer" + str(i))
			if fadein.is_playing():
				var fadeout = get_node("FadeOutAuxBGMPlayer" + str(i))
				var pos = fadein.get_playback_position()
				var vol = fadein.volume_db
				fadein.stop()
				fadeout.stop()
				fadeout.volume_db = vol
				fadeout.stream = fadein.stream
				fadeout.play(pos)
				var duration = (vol - MUTE_DB)/AUX_FADEOUT_SPEED
				$AuxTween.remove(fadeout, "volume_db")
				$AuxTween.interpolate_property(fadeout, "volume_db", vol,
						MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
				$AuxTween.start()
				AUX_BGMS[i-1] = ""
			break
		i += 1


func play_ambience(index: int):
	#Assumes it receives a value starting at 1, shifts to compensate
	var name = AMBIENCE_NAME_MAP[index-1]
	
	#Get a random ambience variation, not repeating the last one
	randomize()
	var number = randi()%AMBIENCE_VARIATIONS + 1
	if last_ambience_bgm_idx:
		while number == last_ambience_bgm_idx:
			number = randi()%AMBIENCE_VARIATIONS + 1
	last_ambience_bgm_idx = number
	
	var source_name = name + "_ambience_" + str(number)
	if not BGMS.has(source_name):
		push_error("Not a valid ambience bgm: " + source_name)
		assert(false)
	
	play_aux_bgm(source_name)


#SFX Methods

func get_sfx_player():
	var player = $SFXS.get_child(cur_sfx_player)
	cur_sfx_player = (cur_sfx_player+ 1)%MAX_SFXS
	return player


func get_idle_sfx_player():
	for player in $IdleSFXs.get_children():
		if not player.is_playing():
			return player
	push_error("Don't have a free idle sfx player")
	assert(false)


func has_sfx(name: String):
	return SFXS.has(name)


func play_sfx(name: String, override_pitch = false, db_mod := 0.0):
	if not SFXS.has(name):
		push_error("Not a valid sfx name: " + name)
		assert(false)
	
	#Check if sfxs was just played, don't playit if thats the case
	if just_played_sfxs.has(name):
		return
	just_played_sfxs[name] = MIN_DUPLICATE_INTERVAL

	var sfx = SFXS[name]
	var player = get_sfx_player()
	player.stop()
	
	player.stream.audio_stream = sfx.asset
	
	randomize()
	var vol = sfx.base_db + rand_range(-sfx.random_db_var, sfx.random_db_var)
	player.volume_db = vol + db_mod
	
	if override_pitch:
		override_pitch = max(override_pitch, 0.001)
		player.pitch_scale = override_pitch
	else:
		player.pitch_scale = sfx.base_pitch
	player.stream.random_pitch = 1.0 + sfx.random_pitch_var
	
	player.play()
	
	return player


func get_sfx_duration(name: String):
	if not SFXS.has(name):
		push_error("Not a valid sfx name: " + name)
		assert(false)
	return SFXS[name].asset.get_length()


func play_enemy_sfx(enemy: String, type:String, delay := 0.0):
	if not LOCS.has(enemy) or not LOCS[enemy].has(type):
		push_error("There isn't a " + type + " sfx file for this enemy: " + str(enemy))
		return
		
	var sfx = LOCS[enemy][type]
	#If there are variations, pick one at random
	if typeof(sfx) == TYPE_ARRAY:
		sfx = sfx[randi()%sfx.size()]
		
		#Try to play different variation each time
		if not just_played_variations.has(enemy):
			just_played_variations[enemy] = {}
		if not just_played_variations[enemy].has(type):
			just_played_variations[enemy][type] = sfx
		else:
			var variations = LOCS[enemy][type]
			if variations.size() > 1:
				while just_played_variations[enemy][type] == sfx:
					sfx = variations[randi()%variations.size()]
				just_played_variations[enemy][type] = sfx
	var player
	
	if type == "idle":
		if CUR_IDLE_SFX.has(enemy):
			#Already has this enemy sfx playing
			return
		player = get_idle_sfx_player()
		CUR_IDLE_SFX[enemy] = player
		
		#Get random initial position
		randomize()
		player.seek(rand_range(0.0, sfx.asset.get_length()))
	else:
		player = get_sfx_player()
		

	player.stop()
	
	randomize()
	var vol = sfx.base_db + rand_range(-sfx.random_db_var, sfx.random_db_var)
	player.volume_db = vol
	
	player.pitch_scale = sfx.base_pitch
	player.stream.random_pitch = 1.0 + sfx.random_pitch_var
	
	player.stream.audio_stream = sfx.asset
	
	if delay >= 0:
		yield(get_tree().create_timer(delay), "timeout")
	
	player.play()
	return player


func stop_enemy_idle_sfx(enemy):
	if CUR_IDLE_SFX.has(enemy):
		CUR_IDLE_SFX[enemy].stop()
		CUR_IDLE_SFX.erase(enemy)


func stop_all_enemy_idle_sfx():
	for name in CUR_IDLE_SFX.keys():
		stop_enemy_idle_sfx(name)
