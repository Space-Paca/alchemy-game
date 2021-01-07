extends Control

signal closed

const REAGENT_TRANSMUTED = preload("res://game/blacksmith/ReagentTransmuted.tscn")

onready var reagent_list = $ClickableReagentList
onready var main_buttons = $MainButtons

var player
var map_node : MapNode
var state
var chosen_reagent_index
var chosen_transmutation = null
var index_map = []


func setup(node, _player):
	main_buttons.show()
	reagent_list.clear()
	reagent_list.hide()
	$UpgradingReagent.hide()
	player = _player
	state = "start"
	map_node = node

func update_reagent_list(type: String):
	index_map = []
	var reagents = []
	var index = 0
	for reagent in player.bag:
		if type == "upgrade":
			if not reagent.upgraded:
				reagents.append({"type": reagent.type, "upgraded": reagent.upgraded})
				index_map.append(index)
		elif type == "transmute":
			var data = ReagentDB.get_from_name(reagent.type)
			if not data.transmutations.empty():
				reagents.append({"type": reagent.type, "upgraded": reagent.upgraded})
				index_map.append(index)
		else:
			assert(false, "Not a valid type to update reagent list: " + str(type))
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
	elif state == "upgrading_reagent":
		state = "start"
		main_buttons.show()
		reagent_list.deactivate_reagents()
		reagent_list.hide()
	elif state == "transmuting_reagent":
		state = "start"
		main_buttons.show()
		reagent_list.deactivate_reagents()
		reagent_list.hide()
	elif state == "confirm_reagent_upgrade":
		state = "start"
		main_buttons.show()
		reagent_list.hide()
		reagent_list.deactivate_reagents()
		$UpgradingReagent.hide()
	elif "confirm_reagent_transmute":
		state = "start"
		main_buttons.show()
		reagent_list.hide()
		reagent_list.deactivate_reagents()
		$TransmutingReagent.hide()


func _on_BackButton_pressed():
	back()


func _on_Upgrade_pressed():
	if not update_reagent_list("upgrade"):
		return
	state = "upgrading_reagent"
	main_buttons.hide()
	reagent_list.show()


func _on_ClickableReagentList_reagent_pressed(reagent_name: String, reagent_index: int, upgraded := false):
	reagent_list.activate_reagent(reagent_index)
	chosen_reagent_index = index_map[reagent_index]
	chosen_transmutation = null
	var data = ReagentDB.get_from_name(reagent_name)
	
	if state == "upgrading_reagent" or state == "confirm_reagent_upgrade":
		state = "confirm_reagent_upgrade"
		$UpgradingReagent.show()
		$UpgradingReagent/Reagent/Image.texture = data.image
		$UpgradingReagent/ReagentUpgraded/Image.texture = data.image
		$UpgradingReagent/Reagent/Label.text = data.tooltip % data.effect.value
		$UpgradingReagent/ReagentUpgraded/Label.text = data.tooltip % data.effect.upgraded_value + " Boost " + \
									  data.effect.upgraded_boost.type + " recipes by " + str(data.effect.upgraded_boost.value) + "."
									
	elif state == "transmuting_reagent" or state == "confirm_reagent_transmute":
		state = "confirm_reagent_transmute"
		$TransmutingReagent.show()
		$TransmutingReagent/Reagent/Image.texture = data.image
		if upgraded:
			$TransmutingReagent/Reagent/Upgraded.show()
		else:
			$TransmutingReagent/Reagent/Upgraded.hide()
		for child in $TransmutingReagent/PossibleTransmutations.get_children():
			$TransmutingReagent/PossibleTransmutations.remove_child(child)
		
		var first = true
		for transmutation in data.transmutations:
			var reagent = REAGENT_TRANSMUTED.instance()
			reagent.connect("activate", self, "_on_reagent_transmute_activate", [reagent])
			$TransmutingReagent/PossibleTransmutations.add_child(reagent)
			reagent.setup(transmutation, upgraded)
			if first:
				first = false
				reagent.activate()
	else:
		assert(false, "Not a valid state when clicking reagents: " + str(state))



func _on_ConfirmUpgrade_pressed():
	if player.spend_pearls(1):
		AudioManager.play_sfx("upgrade_reagent")
		player.upgrade_reagent(chosen_reagent_index)
		reagent_list.deactivate_reagents()
		$UpgradingReagent.hide()
		state = "upgrading_reagent"
		if not update_reagent_list("upgrade"):
			back()
	else:
		AudioManager.play_sfx("error")


func _on_Transmute_pressed():
	if not update_reagent_list("transmute"):
		return
	state = "transmuting_reagent"
	main_buttons.hide()
	reagent_list.show()


func _on_TransmuteConfirmUpgrade_pressed():
	if player.spend_pearls(2):
		AudioManager.play_sfx("transmute_reagent")
		player.transmute_reagent(chosen_reagent_index, chosen_transmutation)
		reagent_list.deactivate_reagents()
		$TransmutingReagent.hide()
		state = "transmuting_reagent"
		if not update_reagent_list("transmute"):
			back()
	else:
		AudioManager.play_sfx("error")


func _on_reagent_transmute_activate(reagent):
	if chosen_transmutation:
		AudioManager.play_sfx("click_possible_transmutation")
	chosen_transmutation = reagent.reagent
	for child in $TransmutingReagent/PossibleTransmutations.get_children():
		if child != reagent:
			child.deactivate()
