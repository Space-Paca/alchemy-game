extends Node

const FADEOUT_SPEED = 30
const FADEIN_SPEED = 30
const MUTE_DB = -60
const NORMAL_DB = -5
const MAX_LAYERS = 3
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
