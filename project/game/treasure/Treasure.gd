extends Control

signal closed

const ARTIFACTS_NUMBER = 2
const ARTIFACT_LOOT = preload("res://game/treasure/ArtifactLoot.tscn")

var map_node : MapNode
var player

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
		var filtered_artifacts = filter_player_artifacts(player, ArtifactDB.get_artifacts_data(artifact_rarity))
		filtered_artifacts.shuffle()
		while(filtered_artifacts.size() > 0 and artifacts_found.size() < ARTIFACTS_NUMBER):
			artifacts_found.append(filtered_artifacts.pop_front())
		if artifacts_found.size() == ARTIFACTS_NUMBER:
			break
		level += 1
	
	if artifacts_found.size() == 0:
		$AllArtifacts.show()
		$BackButton.text = "Cool"
	else:
		for artifact in artifacts_found:
			var loot = ARTIFACT_LOOT.instance()
			$Artifacts.add_child(loot)
			loot.setup(artifact)
			loot.connect("pressed", self, "_on_loot_pressed")
	
	AudioManager.play_sfx("enter_treasure_room")

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

func filter_player_artifacts(_player, pool):
	var filtered = []
	for artifact in pool:
		if not _player.has_artifact(artifact.id):
			filtered.append(artifact)
	
	return filtered

func reset_room():
	reset()
	map_node.set_type(MapNode.EMPTY)

func reset():
	$AllArtifacts.hide()
	$BackButton.text = "Ignore"
	for artifact in $Artifacts.get_children():
		$Artifacts.remove_child(artifact)

func _on_BackButton_pressed():
	reset_room()
	emit_signal("closed")

func _on_loot_pressed(artifact):
	AudioManager.play_sfx("get_artifact")
	player.add_artifact(artifact.id)
	for art in $Artifacts.get_children():
		art.disable()
	
	reset_room()
	emit_signal("closed")
