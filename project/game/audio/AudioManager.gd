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
const FADEOUT_SPEED = 20
const FADEIN_SPEED = 24
#Volume
const MUTE_DB = -60
const NORMAL_DB = 0
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
			"apply_favorite": preload("res://assets/audio/sfx/apply_favourite.wav"),
			"buff": preload("res://assets/audio/sfx/buff_generic.wav"),
			"buy": preload("res://assets/audio/sfx/buy.wav"),
			"click": preload("res://assets/audio/sfx/click.wav"),
			"close_recipe_book": preload("res://assets/audio/sfx/close_recipe_book.wav"),
			"combine": preload("res://assets/audio/sfx/combine.wav"),
			"combine_fail": preload("res://assets/audio/sfx/combine_fail.wav"),
			"combine_success": preload("res://assets/audio/sfx/combine_success.wav"),
			"damage_crushing": preload("res://assets/audio/sfx/damage_crushing.wav"),
			"damage_phantom": preload("res://assets/audio/sfx/damage_phantom.wav"),
			"damage_regular": preload("res://assets/audio/sfx/damage_normal.wav"),
			"debuff": preload("res://assets/audio/sfx/debuff_generic.wav"),
			"discard_reagent": preload("res://assets/audio/sfx/discard_reagent.wav"),
			"discover_new_recipe": preload("res://assets/audio/sfx/discover_new_recipe.wav"),
			"dodge": preload("res://assets/audio/sfx/dodge.wav"),
			"draw_reagent": preload("res://assets/audio/sfx/draw_reagent.wav"),
			"drop_reagent": preload("res://assets/audio/sfx/drop_reagent.wav"),
			"error": preload("res://assets/audio/sfx/error.wav"),
			"game_over": preload("res://assets/audio/sfx/game_over.wav"),
			"hover_button": preload("res://assets/audio/sfx/hover_button.wav"),
			"hover_reagent": preload("res://assets/audio/sfx/hover_reagent.wav"),
			"open_recipe_book": preload("res://assets/audio/sfx/open_recipe_book.wav"),
			"pick_reagent": preload("res://assets/audio/sfx/pick_reagent.wav"),
			"shield_breaks": preload("res://assets/audio/sfx/shield_breaks.wav"),
			"shield_gain": preload("res://assets/audio/sfx/shield_gain.wav"),
			"shield_hit": preload("res://assets/audio/sfx/shield_hit.wav"),
			"tooltip_appears": preload("res://assets/audio/sfx/tooltip_appears.wav"),
			"win_boss_battle": preload("res://assets/audio/sfx/win_boss_battle.wav"),
			"win_normal_battle": preload("res://assets/audio/sfx/win_normal_battle.wav"),
			 }
const LOC_PATH = "res://assets/audio/sfx/loc/"

var bgms_last_pos = {"battle": 0, "map":0, "boss1":0}
var cur_bgm = null
var cur_aux_bgm = null
var cur_sfx_player = 1

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
	var duration = (vol - MUTE_DB)/float(FADEOUT_SPEED)
	$Tween.interpolate_property(player, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	$Tween.start()

func play_bgm_layer(layer: int):
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
	var duration = abs(NORMAL_DB - MUTE_DB)/float(FADEIN_SPEED*2)
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
		var duration = (vol - MUTE_DB)/FADEOUT_SPEED
		$AuxTween.interpolate_property(fadeout, "volume_db", vol, MUTE_DB, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		$AuxTween.start()
		cur_aux_bgm = null

func play_sfx(name: String):
	if not SFXS.has(name):
		push_error("Not a valid sfx name: " + name)
		assert(false)
	
	var player = $SFXS.get_node("SFXPlayer"+str(cur_sfx_player))
	player.stop()
	player.stream = SFXS[name]
	player.play()
	
	cur_sfx_player = (cur_sfx_player%MAX_SFXS) + 1
	
