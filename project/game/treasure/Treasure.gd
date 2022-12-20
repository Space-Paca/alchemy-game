extends Control

signal closed
signal room_reset

const ARTIFACTS_NUMBER = 2
const ARTIFACT_LOOT = preload("res://game/treasure/ArtifactLoot.tscn")
const SEASONAL_MOD = {
	"halloween": {
		"ui": Color("ff9126"),
	},
	"eoy_holidays": {
		"ui": Color("00d3f6"),
	},
}

onready var button = $BackButton

var map_node : MapNode
var player


func _ready():
	if Debug.seasonal_event:
		set_seasonal_look(Debug.seasonal_event)


func setup(node, _player, level):
	reset()
	map_node = node
	player = _player
	
	randomize()
	var artifacts_found = []
	
	#Get treasure artifacts that player don't have. Start at given level, but
	#increase if player already has all of that levels artifacts (somehow)
	while(level <= 3):
		var artifact_rarity = get_rarity_by_level(level)
		var filtered_artifacts = filter_player_artifacts(ArtifactDB.get_artifacts_data(artifact_rarity))
		filtered_artifacts.shuffle()
		while(filtered_artifacts.size() > 0 and artifacts_found.size() < ARTIFACTS_NUMBER):
			artifacts_found.append([filtered_artifacts.pop_front(), artifact_rarity])
		if artifacts_found.size() == ARTIFACTS_NUMBER:
			break
		level += 1
	
	if artifacts_found.size() == 0:
		$AllArtifacts.show()
		$BackButton.text = "COOL"
	else:
		var side = "left"
		for artifact_data in artifacts_found:
			var loot = ARTIFACT_LOOT.instance()
			$Artifacts.add_child(loot)
			loot.setup(artifact_data[0], artifact_data[1], side)
			side = "right"
			loot.connect("pressed", self, "_on_loot_pressed")
	
	AudioManager.play_sfx("enter_treasure_room")
	
	enter_animation()


func set_seasonal_look(event_string):
	button.self_modulate = SEASONAL_MOD[event_string].ui


func enter_animation():
	$Artifacts.modulate.a = 1.0
	var i = 1
	var delay = .5
	for artifact in $Artifacts.get_children():
		artifact.modulate.a = 0
		$Tween.interpolate_property(artifact, "modulate:a", 0, 1, .6, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay*i)
		i += 1
	$Tween.start()

func get_rarity_by_level(level):
	match level:
		1:
			return "common"
		2:
			return "uncommon"
		3:
			return "rare"
		_:
			assert(false, "Not a valid floor level number: " + str(level))

func filter_player_artifacts(pool):
	var filtered = []
	for artifact in pool:
		if not player.has_artifact(artifact.id):
			filtered.append(artifact)
	
	return filtered

func reset_room():
	map_node.set_type(MapNode.EMPTY)
	$Tween.interpolate_property($Artifacts, "modulate:a", 1, 0, .7, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	for artifact in $Artifacts.get_children():
		$Artifacts.remove_child(artifact)
	emit_signal("room_reset")
	
func reset():
	$AllArtifacts.hide()
	$BackButton.text = "IGNORE"

func _on_BackButton_pressed():
	reset_room()
	yield(self, "room_reset")
	emit_signal("closed")

func _on_loot_pressed(artifact):
	player.add_artifact(artifact.id)
	for art in $Artifacts.get_children():
		art.disable()
		if art.artifact.id == artifact.id:
			art.collected()
	
	reset_room()
	yield(self, "room_reset")
	emit_signal("closed")
