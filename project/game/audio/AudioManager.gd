extends Node

#Amplify
const MAX_AMPLIFY = 6
const MIN_AMPLIFY = 0
const AMPLIFY_SPEED = 10
#Cutoff
const CUTOFF_SPEED = 15000
const MAX_CUTOFF = 20500
const DANGER_CUTOFF = 10000
const EXTREME_DANGER_CUTOFF = 2000
#Bus
const MASTER_BUS = 0
const BGM_BUS = 1
#Fade
const FADEOUT_SPEED = 30
const FADEIN_SPEED = 30
#Volume
const MUTE_DB = -60
const NORMAL_DB = 0
#Layer
const MAX_LAYERS = 3
#BGM
const BGMS = {"battle-l1": preload("res://assets/audio/bgm/battle_layer_1.ogg"),
			  "battle-l2": preload("res://assets/audio/bgm/battle_layer_2.ogg"),
			  "battle-l3": preload("res://assets/audio/bgm/battle_layer_3.ogg"),
			  "map": preload("res://assets/audio/bgm/map.ogg"),
			 }

var cur_bgm = null

func get_bgm_layer(name, layer):
	return BGMS[name + "-l" + str(layer)]

func play_bgm(name, layers = false):
	if not layers:
		assert(BGMS[name])
	else:
		assert(get_bgm_layer(name, layers))
	
	if cur_bgm:
		stop_bgm()
	
	cur_bgm = name
	
	if not layers:
		$BGMPlayer1.stream = BGMS[name]
		$BGMPlayer1.volume_db = MUTE_DB
		$BGMPlayer1.play()
		var duration = (NORMAL_DB - MUTE_DB)/float(FADEIN_SPEED)
		$Tween.interpolate_property($BGMPlayer1, "volume_db", MUTE_DB, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()
	else:
		for i in range(1, layers + 1):
			var player = get_node("BGMPlayer"+str(i))
			player.stream = get_bgm_layer(name, i)
			player.volume_db = MUTE_DB
			player.play()
			var duration = (NORMAL_DB - MUTE_DB)/float(FADEIN_SPEED)
			$Tween.interpolate_property(player, "volume_db", MUTE_DB, NORMAL_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$Tween.start()

func stop_bgm():
	for i in range(1, MAX_LAYERS + 1):
		var fadein = get_node("BGMPlayer"+str(i))
		var fadeout = get_node("FadeOutBGMPlayer"+str(i))
		var pos = fadein.get_playback_position()
		var vol = fadein.volume_db
		fadein.stop()
		fadeout.stop()
		fadeout.volume_db = vol
		fadeout.stream = fadein.stream
		fadeout.play(pos)
		var duration = (vol - MUTE_DB)/FADEOUT_SPEED
		$Tween.interpolate_property(fadeout, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()


func stop_bgm_layer(layer):
	var player = get_node("BGMPlayer"+str(layer))
	var vol = player.volume_db
	var duration = (vol - MUTE_DB)/float(FADEOUT_SPEED)
	$Tween.interpolate_property(player, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()

func play_bgm_layer(layer):
	var player = get_node("BGMPlayer"+str(layer))
	var vol = player.volume_db
	var duration = (NORMAL_DB - vol)/float(FADEIN_SPEED)
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

func start_bgm_effect(type):
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
		
