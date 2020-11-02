extends Control

signal closed

onready var reagent_list = $ClickableReagentList

var player
var map_node : MapNode
var state
var chosen_reagent_index
var index_map = []


func setup(node, _player):
	$Upgrade.show()
	reagent_list.clear()
	reagent_list.hide()
	$UpgradingReagent.hide()
	player = _player
	$PlayerInfo.update_gems(player.gems)
	state = "start"
	map_node = node

func update_reagent_list():
	index_map = []
	var reagents = []
	var index = 0
	for reagent in player.bag:
		if not reagent.upgraded:
			reagents.append(reagent.type)
			index_map.append(index)
		index += 1
	
	if reagents.size() == 0:
		AudioManager.play_sfx("error")
		return false
		
	reagent_list.clear()
	reagent_list.populate(reagents)
	
	return true


func back():
	if state == "start":
		emit_signal("closed")
	elif state == "picking_reagent":
		state = "start"
		$Upgrade.show()
		reagent_list.deactivate_reagents()
		reagent_list.hide()
	elif state == "confirm_reagent":
		state = "start"
		$Upgrade.show()
		reagent_list.hide()
		reagent_list.deactivate_reagents()
		$UpgradingReagent.hide()


func _on_BackButton_pressed():
	back()


func _on_Upgrade_pressed():
	if not update_reagent_list():
		return
	state = "picking_reagent"
	$Upgrade.hide()
	reagent_list.show()


func _on_ClickableReagentList_reagent_pressed(reagent_name: String, reagent_index: int):
	state = "confirm_reagent"
	reagent_list.activate_reagent(reagent_index)
	
	chosen_reagent_index = index_map[reagent_index]
	
	var data = ReagentDB.get_from_name(reagent_name)
	$UpgradingReagent.show()
	$UpgradingReagent/Reagent/Image.texture = data.image
	$UpgradingReagent/ReagentUpgraded/Image.texture = data.image
	$UpgradingReagent/Reagent/Label.text = data.tooltip % data.effect.value
	$UpgradingReagent/ReagentUpgraded/Label.text = data.tooltip % data.effect.upgraded_value + " Boost " + \
								  data.effect.upgraded_boost.type + " recipes by " + str(data.effect.upgraded_boost.value) + "."


func _on_ConfirmUpgrade_pressed():
	if player.spend_gems(1):
		AudioManager.play_sfx("upgrade_reagent")
		$PlayerInfo.update_gems(player.gems)
		player.upgrade_reagent(chosen_reagent_index)
		reagent_list.deactivate_reagents()
		$UpgradingReagent.hide()
		state = "picking_reagent"
		if not update_reagent_list():
			back()
	else:
		AudioManager.play_sfx("error")
