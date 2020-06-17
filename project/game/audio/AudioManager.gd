extends Node

#Amplify
const MAX_AMPLIFY = 6 #Amplify effect when player is in extreme danger
const MIN_AMPLIFY = 0 #Value to remove effect
const AMPLIFY_SPEED = 10 #Speed to increase or decrease amplify effect
#Cutoff
const CUTOFF_SPEED = 15000 #Speed to change between cutoffs
const MAX_CUTOFF = 20500 #Cutoff when player is > 50hp (aka no effect)
const DANGER_CUTOFF = 10000 #Cutoff when player is < 50hp
const EXTREME_DANGER_CUTOFF = 2000 #Cutoff when player is < 20hp
#Bus
const MASTER_BUS = 0
const BGM_BUS = 1
#Fade
const FADEOUT_SPEED = 20 #Speed bgms fadein
const FADEIN_SPEED = 60 #Speed bgms fadeout
const TRACK_FADEOUT_SPEED = 20 #Speed individual bgm tracks fadein
const TRACK_FADEIN_SPEED = 60 #Speed individual bgm tracks fadeout
const AUX_FADEOUT_SPEED = 40 #Speed aux bgm fadein
const AUX_FADEIN_SPEED = 60 #Speed aux bgm fadeout
#Volume
const MUTE_DB = -60 #Muted volume
#Layer
const MAX_LAYERS = 3
#BGM
const BGM_PATH = "res://database/audio/bgms/"
onready var BGMS = {}
#AUX
onready var AUX_BGMS = ["","",""]
const AMBIENCE_VARIATIONS = 3
#SFX
const MAX_SFXS = 10
const SFX_PATH = "res://database/audio/sfxs/"
onready var SFXS = {}
onready var CUR_IDLE_SFX = {}
#LOCS
const LOC_PATH = "res://database/audio/locs/"
onready var LOCS = {}

var bgms_last_pos = {"battle": 0, "map":0, "boss1":0, "shop":0, "menu":0, "rest":0, "blacksmith":0}
var cur_bgm = null
var cur_aux_bgm = null
var using_layers = false
var cur_sfx_player := 1

func _ready():
	setup_bgms()
	setup_sfxs()
	setup_locs()

func setup_bgms():
	var dir = Directory.new()
	if dir.open(BGM_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				#Found enemy sfx file, creating data on memory
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
				#Found enemy sfx file, creating data on memory
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
		var regex = RegEx.new()
		while file_name != "":
			if not dir.current_is_dir() and file_name != "." and file_name != "..":
				#Found enemy loc, first parse name, then create data on memory
				#Check for die sfx
				regex.compile("(\\w+)_dies.tres")
				var result = regex.search(file_name)
				if result:
					var name = result.get_string(1)
					if not LOCS.has(name):
						LOCS[name] = {} 
					LOCS[name].dies = load(LOC_PATH + file_name)
				#Check for hit
				else:
					regex.compile("(\\w+)_hit_var(\\d+).tres")
					result = regex.search(file_name)
					if result:
						var name = result.get_string(1)
						var number = result.get_string(2)
						if not LOCS.has(name):
							LOCS[name] = {} 
						LOCS[name]["hit_var"+str(number)] = load(LOC_PATH + file_name)
					#Check for idle
					else:
						regex.compile("(\\w+)_idle.tres")
						result = regex.search(file_name)
						if result:
							var name = result.get_string(1)
							if not LOCS.has(name):
								LOCS[name] = {} 
							LOCS[name]["idle"] = load(LOC_PATH + file_name)
						#Check for spawn
						else:
							regex.compile("(\\w+)_spawn_var(\\d+).tres")
							result = regex.search(file_name)
							if result:
								var name = result.get_string(1)
								var number = result.get_string(2)
								if not LOCS.has(name):
									LOCS[name] = {} 
								LOCS[name]["spawn_var"+str(number)] = load(LOC_PATH + file_name)
						
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access locutions path.")
		assert(false)


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
			$BGMPlayer1.play(bgms_last_pos[name])
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
				player.play(bgms_last_pos[name])
			var duration = (layer.base_db - MUTE_DB)/float(FADEIN_SPEED)
			$Tween.remove(player, "volume_db")
			$Tween.interpolate_property(player, "volume_db", MUTE_DB, layer.base_db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()

func stop_bgm():
	stop_all_aux_bgm()
	remove_bgm_effect()
	for i in range(1, MAX_LAYERS + 1):
		var fadein = get_node("BGMPlayer"+str(i))
		if fadein.is_playing():
			var fadeout = get_node("FadeOutBGMPlayer"+str(i))
			var pos = fadein.get_playback_position()
			bgms_last_pos[cur_bgm] = pos
			var vol = fadein.volume_db
			fadein.stop()
			fadeout.stop()
			fadeout.volume_db = vol
			fadeout.stream = fadein.stream
			fadeout.play(pos)
			var duration = (vol - MUTE_DB)/FADEOUT_SPEED
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
	$AuxTween.interpolate_property(player, "volume_db", MUTE_DB, db, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
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
				$AuxTween.interpolate_property(fadeout, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
				$AuxTween.start()
				AUX_BGMS[i-1] = ""
			break
		i += 1

func play_ambience(name: String):
	#Get a random ambience variation
	randomize()
	var number = randi()%AMBIENCE_VARIATIONS + 1
	
	var source_name = name + "_ambience_" + str(number)
	if not BGMS.has(source_name):
		push_error("Not a valid ambience bgm: " + source_name)
		assert(false)
	
	play_aux_bgm(source_name)

func get_sfx_player():
	var player = $SFXS.get_node("SFXPlayer"+str(cur_sfx_player))
	cur_sfx_player = (cur_sfx_player%MAX_SFXS) + 1
	return player

func get_idle_sfx_player():
	for player in $IdleSFXs.get_children():
		if not player.is_playing():
			return player
	push_error("Don't have a free idle sfx player")
	assert(false)

func has_sfx(name: String):
	return SFXS.has(name)

func play_sfx(name: String, override_pitch := 1):
	if not SFXS.has(name):
		push_error("Not a valid sfx name: " + name)
		assert(false)
	var sfx = SFXS[name]
	var player = get_sfx_player()
	player.stop()
	
	player.stream.audio_stream = sfx.asset
	
	randomize()
	var vol = sfx.base_db + rand_range(-sfx.random_db_var, sfx.random_db_var)
	player.volume_db = vol
	
	if override_pitch != 1:
		player.pitch_scale = override_pitch
	else:
		player.pitch_scale = sfx.base_pitch
	player.stream.random_pitch = 1.0 + sfx.random_pitch_var

	player.play()

func get_sfx_duration(name: String):
	if not SFXS.has(name):
		push_error("Not a valid sfx name: " + name)
		assert(false)
	return SFXS[name].asset.get_length()

func play_enemy_sfx(sfx, given_player = null):
	var player
	if not given_player:
		player= get_sfx_player()
	else:
		player = given_player
	player.stop()
	
	randomize()
	var vol = sfx.base_db + rand_range(-sfx.random_db_var, sfx.random_db_var)
	player.volume_db = vol
	
	player.pitch_scale = sfx.base_pitch
	player.stream.random_pitch = 1.0 + sfx.random_pitch_var
	
	player.stream.audio_stream = sfx.asset
	
	player.play()
	return player

func play_enemy_hit_sfx(enemy: String):
	#Get a random hit sfx
	randomize()
	var number = randi()%3 + 1
	
	if not LOCS.has(enemy) or not LOCS[enemy].has("hit_var"+str(number)):
		push_error("There isn't a hit sfx file for this enemy: " + str(enemy))
		assert(false)
	
	play_enemy_sfx(LOCS[enemy]["hit_var"+str(number)])

func play_enemy_spawn_sfx(enemy: String):
	#Get a random hit sfx
	randomize()
	var number = randi()%3 + 1
	
	if not LOCS.has(enemy) or not LOCS[enemy].has("spawn_var"+str(number)):
		push_error("There isn't a spawn sfx file for this enemy: " + str(enemy))
		assert(false)
	
	play_enemy_sfx(LOCS[enemy]["spawn_var"+str(number)])

func play_enemy_idle_sfx(enemy):
	if not LOCS.has(enemy) or not LOCS[enemy].has("idle"):
		push_error("There isn't an idle sfx file for this enemy: " + str(enemy))
		assert(false)
	
	if CUR_IDLE_SFX.has(enemy):
		#Already has this enemy sfx playing
		return

	
	var sfx = LOCS[enemy].idle
	var player = get_idle_sfx_player()
	CUR_IDLE_SFX[enemy] = player
	
	#Get random initial position
	randomize()
	var pos = rand_range(0.0, sfx.asset.get_length())
	player.seek(pos)
	
	return play_enemy_sfx(sfx, player)

func stop_enemy_idle_sfx(enemy):
	if CUR_IDLE_SFX.has(enemy):
		CUR_IDLE_SFX[enemy].stop()
		CUR_IDLE_SFX.erase(enemy)

func stop_all_enemy_idle_sfx():
	for name in CUR_IDLE_SFX.keys():
		stop_enemy_idle_sfx(name)

func play_enemy_dies_sfx(enemy):
	if not LOCS.has(enemy) or not LOCS[enemy].has("dies"):
		push_error("There isn't a death sfx file for this enemy: " + str(enemy))
		assert(false)
	
	play_enemy_sfx(LOCS[enemy].dies)
