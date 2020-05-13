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
const FADEOUT_SPEED = 40 #Speed bgms fadein
const FADEIN_SPEED = 60 #Speed bgms fadeout
const TRACK_FADEOUT_SPEED = 20 #Speed individual bgm tracks fadein
const TRACK_FADEIN_SPEED = 30 #Speed individual bgm tracks fadeout
const AUX_FADEOUT_SPEED = 40 #Speed aux bgm (heartbeat only for now) fadein
const AUX_FADEIN_SPEED = 60 #Speed aux bgm (heartbeat only for now) fadeout
#Volume
const MUTE_DB = -60 #Muted volume
const NORMAL_DB = 0 #Regular volume
const LOWERED_DB = -20 #Lowered volume (used in victory or death screens)
#Layer
const MAX_LAYERS = 3
#BGM
const BGMS = {"battle-l1": preload("res://assets/audio/bgm/battle_1_layer_1.ogg"),
			  "battle-l2": preload("res://assets/audio/bgm/battle_1_layer_2.ogg"),
			  "battle-l3": preload("res://assets/audio/bgm/battle_1_layer_3.ogg"),
			  "boss1-l1": preload("res://assets/audio/bgm/boss_1_layer_1.ogg"),
			  "boss1-l2": preload("res://assets/audio/bgm/boss_1_layer_2.ogg"),
			  "boss1-l3": preload("res://assets/audio/bgm/boss_1_layer_3.ogg"),
			  "heart-beat": preload("res://assets/audio/bgm/battle_heart_beat.ogg"),
			  "map": preload("res://assets/audio/bgm/map_1.ogg"),
			  "shop": preload("res://assets/audio/bgm/shop.ogg"),
			 }
#SFX
const MAX_SFXS = 10
const SFXS = {
			"apply_favorite": {"asset" : preload("res://assets/audio/sfx/apply_favourite.wav"),
							   "base_db" : 0,
							   "random_db_var" : 0,
							   "base_pitch" : 1,
							   "random_pitch_var" : 0,
							  },
			"buff": {"asset" : preload("res://assets/audio/sfx/buff_generic.wav"),
					 "base_db" : -2,
					 "random_db_var" : 0,
					 "base_pitch" : 1,
					 "random_pitch_var" : 0,
				  },
			"buy": {"asset" : preload("res://assets/audio/sfx/buy.wav"),
					"base_db" : 0,
					"random_db_var" : 0,
					"base_pitch" : 1,
					"random_pitch_var" : 0,
				   },
			"click": {"asset" : preload("res://assets/audio/sfx/click.wav"),
					  "base_db" : 2,
					  "random_db_var" : 0.5,
					  "base_pitch" : 1,
					  "random_pitch_var" : 0.5,
					 },
			"close_recipe_book": {"asset" : preload("res://assets/audio/sfx/close_recipe_book.wav"),
							   "base_db" : -3,
							   "random_db_var" : 1,
							   "base_pitch" : 1,
							   "random_pitch_var" : 1,
							  },
			"combine": {"asset" : preload("res://assets/audio/sfx/combine.wav"),
						"base_db" : 3	,
						"random_db_var" : 0,
						"base_pitch" : 1,
						"random_pitch_var" : 0,
					   },
			"combine_fail": {"asset" : preload("res://assets/audio/sfx/combine_fail.wav"),
							 "base_db" : 0,
							 "random_db_var" : 0,
							 "base_pitch" : 1,
							 "random_pitch_var" : 0,
							 },
			"combine_success": {"asset" : preload("res://assets/audio/sfx/combine_success.wav"),
								"base_db" : 0,
								"random_db_var" : 0,
								"base_pitch" : 1,
								"random_pitch_var" : 0,
							   },
			"damage_crushing": {"asset" : preload("res://assets/audio/sfx/damage_crushing.wav"),
								"base_db" : 0,
								"random_db_var" : 0,
								"base_pitch" : 1,
								"random_pitch_var" : 0,
							   },
			"damage_phantom": {"asset" : preload("res://assets/audio/sfx/damage_phantom.wav"),
							   "base_db" : 0,
							   "random_db_var" : 0,
							   "base_pitch" : 1,
							   "random_pitch_var" : 0,
							  },
			"damage_regular": {"asset" : preload("res://assets/audio/sfx/damage_normal.wav"),
							   "base_db" : 10,
							   "random_db_var" : 0,
							   "base_pitch" : 1,
							   "random_pitch_var" : 0,
							  },
			"debuff": {"asset" : preload("res://assets/audio/sfx/debuff_generic.wav"),
					   "base_db" : 0,
					   "random_db_var" : 0,
					   "base_pitch" : 1,
					   "random_pitch_var" : 0,
					  },
			"discard_reagent": {"asset" : preload("res://assets/audio/sfx/discard_reagent.wav"),
								"base_db" : 0,
								"random_db_var" : 0,
								"base_pitch" : 1,
								"random_pitch_var" : 0,
							  },
			"discover_new_recipe": {"asset" : preload("res://assets/audio/sfx/discover_new_recipe.wav"),
									"base_db" : 0,
									"random_db_var" : 0,
									"base_pitch" : 1,
									"random_pitch_var" : 0,
									},
			"dodge": {"asset" : preload("res://assets/audio/sfx/dodge.wav"),
					  "base_db" : 0,
					  "random_db_var" : 0,
					  "base_pitch" : 1,
					  "random_pitch_var" : 0,
					  },
			"draw_reagent": {"asset" : preload("res://assets/audio/sfx/draw_reagent.wav"),
							 "base_db" : 0,
							 "random_db_var" : 0,
							 "base_pitch" : 1,
							 "random_pitch_var" : 0,
							},
			"drop_reagent": {"asset" : preload("res://assets/audio/sfx/drop_reagent.wav"),
							 "base_db" : -3,
							 "random_db_var" : 3,
							 "base_pitch" : 3,
							 "random_pitch_var" : 0.05,
							},
			"error": {"asset" : preload("res://assets/audio/sfx/error.wav"),
					  "base_db" : 0,
					  "random_db_var" : 0,
					  "base_pitch" : 1,
					  "random_pitch_var" : 0,
					 },
			"game_over": {"asset" : preload("res://assets/audio/sfx/game_over.wav"),
						  "base_db" : 0,
						  "random_db_var" : 0,
						  "base_pitch" : 1,
						  "random_pitch_var" : 0,
							  },
			"get_coins": {"asset" : preload("res://assets/audio/sfx/get_coins.wav"),
						  "base_db" : 0,
						  "random_db_var" : 0,
						  "base_pitch" : 1,
						  "random_pitch_var" : 0,
						 },
			"get_loot": {"asset" : preload("res://assets/audio/sfx/get_loot.wav"),
						 "base_db" : 0,
						 "random_db_var" : 1,
						 "base_pitch" : 1,
						 "random_pitch_var" : 0.5,
						},
			"hover_button": {"asset" : preload("res://assets/audio/sfx/hover_button.wav"),
							 "base_db" : -8,
							 "random_db_var" : 1,
							 "base_pitch" : 1,
							 "random_pitch_var" : 0.2,
							},
			"hover_reagent": {"asset" : preload("res://assets/audio/sfx/hover_reagent.wav"),
							  "base_db" : -10,
							  "random_db_var" : 1,
							  "base_pitch" : 2,
							  "random_pitch_var" : 1,
							  },
			"open_recipe_book": {"asset" : preload("res://assets/audio/sfx/open_recipe_book.wav"),
								 "base_db" : 0,
								 "random_db_var" : 0,
								 "base_pitch" : 1,
								 "random_pitch_var" : 1,
								},
			"pick_reagent": {"asset" : preload("res://assets/audio/sfx/pick_reagent.wav"),
							 "base_db" : 0,
							 "random_db_var" : 3,
							 "base_pitch" : 1,
							 "random_pitch_var" : 0.5,
							},
			"shield_breaks": {"asset" : preload("res://assets/audio/sfx/shield_breaks.wav"),
							  "base_db" : 0,
							  "random_db_var" : 0,
							  "base_pitch" : 1,
							  "random_pitch_var" : 0,
							 },
			"shield_gain": {"asset" : preload("res://assets/audio/sfx/shield_gain.wav"),
							"base_db" : -10,
							"random_db_var" : 0,
							"base_pitch" : 1,
							"random_pitch_var" : 0,
							},
			"shield_hit": {"asset" : preload("res://assets/audio/sfx/shield_hit.wav"),
						   "base_db" : -10,
						   "random_db_var" : 0,
						   "base_pitch" : 1,
						   "random_pitch_var" : 0,
						  },
			"tooltip_appears": {"asset" : preload("res://assets/audio/sfx/tooltip_appears.wav"),
								"base_db" : -11,
								"random_db_var" : 3,
								"base_pitch" : 2,
								"random_pitch_var" : 0.01,
							   },
			"win_boss_battle": {"asset" : preload("res://assets/audio/sfx/win_boss_battle.wav"),
								"base_db" : 0,
								"random_db_var" : 0,
								"base_pitch" : 1,
								"random_pitch_var" : 0,
							   },
			"win_normal_battle": {"asset" : preload("res://assets/audio/sfx/win_normal_battle.wav"),
								  "base_db" : 0,
								  "random_db_var" : 0,
								  "base_pitch" : 1,
								  "random_pitch_var" : 0,
								 },
			 }
#LOCS
const LOC_PATH = "res://assets/audio/sfx/loc/"
onready var LOCS = {}

var bgms_last_pos = {"battle": 0, "map":0, "boss1":0}
var cur_bgm = null
var cur_aux_bgm = null
var using_layers = false
var cur_sfx_player := 1

func _ready():
	setup_locs()

func setup_locs():
	var dir = Directory.new()
	if dir.open(LOC_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				#Found enemy loc directory, creating data on memory
				LOCS[file_name] = {}
				LOCS[file_name].dies = load(LOC_PATH + file_name + "/dies.wav")
				for i in range(1, 4):
					LOCS[file_name]["hit_var"+str(i)] = load(LOC_PATH + file_name + \
													   "/hit_var" + str(i) +  ".wav")
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access locutions path.")
		assert(false)


func get_bgm_layer(name, layer):
	return BGMS[name + "-l" + str(layer)]

func lower_bgm_volume():
	if not using_layers:
		var duration = abs(LOWERED_DB - $BGMPlayer1.volume_db)/float(FADEOUT_SPEED)
		$Tween.interpolate_property($BGMPlayer1, "volume_db", $BGMPlayer1.volume_db, LOWERED_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	else:
		for i in range(1, using_layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			var duration = abs(LOWERED_DB - player.volume_db)/float(FADEOUT_SPEED)
			$Tween.interpolate_property(player, "volume_db", player.volume_db, LOWERED_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()

func resume_bgm_volume():
	if not using_layers:
		var duration = abs(NORMAL_DB - $BGMPlayer1.volume_db)/float(FADEIN_SPEED)
		$Tween.interpolate_property($BGMPlayer1, "volume_db", $BGMPlayer1.volume_db, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	else:
		for i in range(1, using_layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			var duration = abs(NORMAL_DB - player.volume_db)/float(FADEIN_SPEED)
			$Tween.interpolate_property(player, "volume_db", player.volume_db, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()

func play_bgm(name, layers = false):
	if not layers:
		assert(BGMS[name])
	else:
		assert(get_bgm_layer(name, layers))
	
	if cur_bgm:
		stop_bgm()
	
	cur_bgm = name
	using_layers = layers
	
	if not using_layers:
		$BGMPlayer1.stream = BGMS[name]
		$BGMPlayer1.volume_db = MUTE_DB
		$BGMPlayer1.play(bgms_last_pos[name])
		var duration = (NORMAL_DB - MUTE_DB)/float(FADEIN_SPEED)
		$Tween.interpolate_property($BGMPlayer1, "volume_db", MUTE_DB, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()
	else:
		for i in range(1, layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			player.stream = get_bgm_layer(name, i)
			player.volume_db = MUTE_DB
			player.play(bgms_last_pos[name])
			var duration = (NORMAL_DB - MUTE_DB)/float(FADEIN_SPEED)
			$Tween.interpolate_property(player, "volume_db", MUTE_DB, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()

func stop_bgm():
	stop_aux_bgm()
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
			$Tween.interpolate_property(fadeout, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()


func stop_bgm_layer(layer: int):
	var player = get_node("BGMPlayer"+str(layer))
	var vol = player.volume_db
	var duration = (vol - MUTE_DB)/float(TRACK_FADEOUT_SPEED)
	$Tween.interpolate_property(player, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()

func play_bgm_layer(layer: int):
	var player = get_node("BGMPlayer"+str(layer))
	var vol = player.volume_db
	var duration = (NORMAL_DB - vol)/float(TRACK_FADEIN_SPEED)
	$Tween.interpolate_property(player, "volume_db", vol, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()

func remove_bgm_effect():
	#remove filter
	if AudioServer.is_bus_effect_enabled(BGM_BUS, 0):
		var effect = AudioServer.get_bus_effect(BGM_BUS, 0)
		var duration = abs(MAX_CUTOFF - effect.cutoff_hz)/CUTOFF_SPEED
		$BusEffectTween.interpolate_property(effect, "cutoff_hz", effect.cutoff_hz, MAX_CUTOFF, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
		yield($BusEffectTween, "tween_completed")
		AudioServer.set_bus_effect_enabled(BGM_BUS, 0, false)
	#remove amplify	
	var effect = AudioServer.get_bus_effect(BGM_BUS, 1)
	var duration = abs(MIN_AMPLIFY - effect.volume_db)/AMPLIFY_SPEED
	$BusEffectTween.interpolate_property(effect, "volume_db", effect.volume_db, MIN_AMPLIFY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$BusEffectTween.start()

func start_bgm_effect(type: String):
	if type == "danger":
		#filter
		var effect = AudioServer.get_bus_effect(BGM_BUS, 0)
		var duration = abs(DANGER_CUTOFF - effect.cutoff_hz)/CUTOFF_SPEED
		AudioServer.set_bus_effect_enabled(BGM_BUS, 0, true)
		$BusEffectTween.interpolate_property(effect, "cutoff_hz", effect.cutoff_hz, DANGER_CUTOFF, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
		
		#remove amplify
		effect = AudioServer.get_bus_effect(BGM_BUS, 1)
		duration = abs(MIN_AMPLIFY - effect.volume_db)/AMPLIFY_SPEED
		$BusEffectTween.interpolate_property(effect, "volume_db", effect.volume_db, MIN_AMPLIFY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
	if type == "extreme-danger":
		#filter
		var effect = AudioServer.get_bus_effect(BGM_BUS, 0)
		var duration = abs(EXTREME_DANGER_CUTOFF - effect.cutoff_hz)/CUTOFF_SPEED
		AudioServer.set_bus_effect_enabled(BGM_BUS, 0, true)
		$BusEffectTween.interpolate_property(effect, "cutoff_hz", effect.cutoff_hz, EXTREME_DANGER_CUTOFF, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()
		
		#amplify
		effect = AudioServer.get_bus_effect(BGM_BUS, 1)
		duration = abs(MAX_AMPLIFY - effect.volume_db)/AMPLIFY_SPEED
		$BusEffectTween.interpolate_property(effect, "volume_db", effect.volume_db, MAX_AMPLIFY, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$BusEffectTween.start()

func play_aux_bgm(name: String):
	if cur_aux_bgm == name:
		return
	
	if cur_aux_bgm:
		stop_aux_bgm()
	
	cur_aux_bgm = name
	
	var player = $AuxBGMPlayer
	player.stream = BGMS[name]
	player.volume_db = MUTE_DB
	player.play()
	var duration = abs(NORMAL_DB - MUTE_DB)/float(AUX_FADEIN_SPEED*2)
	$Tween.interpolate_property(player, "volume_db", MUTE_DB, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()	

func stop_aux_bgm():
	var fadein = $AuxBGMPlayer
	if fadein.is_playing():
		var fadeout =$FadeOutAuxBGMPlayer
		var pos = fadein.get_playback_position()
		var vol = fadein.volume_db
		fadein.stop()
		fadeout.stop()
		fadeout.volume_db = vol
		fadeout.stream = fadein.stream
		fadeout.play(pos)
		var duration = (vol - MUTE_DB)/AUX_FADEOUT_SPEED
		$AuxTween.interpolate_property(fadeout, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$AuxTween.start()
		cur_aux_bgm = null

func get_sfx_player():
	var player = $SFXS.get_node("SFXPlayer"+str(cur_sfx_player))
	cur_sfx_player = (cur_sfx_player%MAX_SFXS) + 1
	return player

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

func play_enemy_hit_sfx(enemy: String):
	#Get a random hit sfx
	randomize()
	var number = randi()%3 + 1
	
	if not LOCS.has(enemy) or not LOCS[enemy].has("hit_var"+str(number)):
		push_error("There isn't a hit sfx file for this enemy: " + str(enemy))
		assert(false)
		
	var sfx = LOCS[enemy]
	var player = get_sfx_player()
	player.stop()
	player.volume_db = 0.0
	player.pitch_scale = 1.0
	player.stream.random_pitch = 1.0
	player.stream.audio_stream = sfx["hit_var"+str(number)]
	player.play()
	
func play_enemy_dies_sfx(enemy):
	if not LOCS.has(enemy) or not LOCS[enemy].has("dies"):
		push_error("There isn't a death sfx file for this enemy: " + str(enemy))
		assert(false)
	
	var sfx = LOCS[enemy]
	var player = get_sfx_player()
	player.stop()
	player.volume_db = 0.0
	player.pitch_scale = 1.0
	player.stream.random_pitch = 1.0
	player.stream.audio_stream = sfx.dies
	player.play()
