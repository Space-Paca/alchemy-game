extends Node


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
		$BGMPlayer1.play()
	else:
		for i in range(1, layers):
			var player = get_node("BGMPlayer"+str(i))
			player.stream = get_bgm_layer(name, i)
			player.play()
	

func stop_bgm():
	for i in range(1, 3):
		get_node("BGMPlayer"+str(i)).stop()
