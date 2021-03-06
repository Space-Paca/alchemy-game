extends Control

signal closed

const REAGENT_TRANSMUTED = preload("res://game/blacksmith/ReagentTransmuted.tscn")

onready var reagent_list = $ClickableReagentList
onready var main_buttons = $MainButtons
onready var transmuting_reagent_tooltip = $TransmutingReagent/Reagent/TooltipCollision
onready var upgrading_reagent_tooltip = $UpgradingReagent/Reagent/TooltipCollision
onready var upgraded_reagent_tooltip = $UpgradingReagent/ReagentUpgraded/TooltipCollision
onready var dialog = $ShopkeeperDialogue

var player
var map_node : MapNode
var state
var chosen_reagent_index
var chosen_transmutation = null
var chosen_reagent_name : String
var chosen_reagent_upgraded : bool
var index_map = []
var tooltips_enabled = false


func setup(node, _player):
	main_buttons.show()
	dialog.show()
	reagent_list.clear()
	reagent_list.hide()
	reagent_list.disable_tooltips()
	player = _player
	state = "start"
	map_node = node
	transmuting_reagent_tooltip.disable()
	remove_transmuting_possibilities()


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
	if reagent_list.visible:
		reagent_list.enable_tooltips()
	else:
		reagent_list.disable_tooltips()
	
	return true


func back():
	if state == "start":
		emit_signal("closed")
	elif state == "upgrading_reagent":
		state = "start"
		main_buttons.show()
		dialog.show()
		reagent_list.deactivate_reagents()
		reagent_list.hide()
		reagent_list.disable_tooltips()
	elif state == "transmuting_reagent":
		state = "start"
		main_buttons.show()
		dialog.show()
		reagent_list.deactivate_reagents()
		reagent_list.hide()
		reagent_list.disable_tooltips()
	elif state == "confirm_reagent_upgrade":
		state = "start"
		main_buttons.show()
		dialog.show()
		reagent_list.hide()
		reagent_list.disable_tooltips()
		reagent_list.deactivate_reagents()
		$UpgradingReagent.hide()
		upgrading_reagent_tooltip.disable()
		upgraded_reagent_tooltip.disable()
	elif "confirm_reagent_transmute":
		state = "start"
		main_buttons.show()
		dialog.show()
		reagent_list.hide()
		reagent_list.disable_tooltips()
		reagent_list.deactivate_reagents()
		$TransmutingReagent.hide()
		transmuting_reagent_tooltip.disable()
		remove_transmuting_possibilities()


func remove_transmuting_possibilities():
	for child in $TransmutingReagent/PossibleTransmutations.get_children():
		$TransmutingReagent/PossibleTransmutations.remove_child(child)
		child.queue_free()


func _on_BackButton_pressed():
	back()


func _on_Upgrade_pressed():
	if not update_reagent_list("upgrade"):
		return
	state = "upgrading_reagent"
	main_buttons.hide()
	dialog.hide()
	reagent_list.show()
	reagent_list.enable_tooltips()


func _on_ClickableReagentList_reagent_pressed(reagent_name: String, reagent_index: int, upgraded := false):
	reagent_list.activate_reagent(reagent_index)
	chosen_reagent_index = index_map[reagent_index]
	chosen_transmutation = null
	chosen_reagent_name = reagent_name
	chosen_reagent_upgraded = upgraded
	var data = ReagentDB.get_from_name(reagent_name)
	
	if state == "upgrading_reagent" or state == "confirm_reagent_upgrade":
		state = "confirm_reagent_upgrade"
		$UpgradingReagent.show()
		upgrading_reagent_tooltip.enable()
		upgraded_reagent_tooltip.enable()
		$UpgradingReagent/Reagent/Image.texture = data.image
		$UpgradingReagent/ReagentUpgraded/Image.texture = data.image
	elif state == "transmuting_reagent" or state == "confirm_reagent_transmute":
		state = "confirm_reagent_transmute"
		$TransmutingReagent.show()
		transmuting_reagent_tooltip.enable()
		$TransmutingReagent/Reagent/Image.texture = data.image
		if upgraded:
			$TransmutingReagent/Reagent/Upgraded.show()
		else:
			$TransmutingReagent/Reagent/Upgraded.hide()
		remove_transmuting_possibilities()
		
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
		upgrading_reagent_tooltip.disable()
		upgraded_reagent_tooltip.disable()
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
	dialog.hide()
	reagent_list.show()
	reagent_list.enable_tooltips()


func _on_TransmuteConfirmUpgrade_pressed():
	if player.spend_pearls(2):
		AudioManager.play_sfx("transmute_reagent")
		player.transmute_reagent(chosen_reagent_index, chosen_transmutation)
		reagent_list.deactivate_reagents()
		$TransmutingReagent.hide()
		transmuting_reagent_tooltip.disable()
		remove_transmuting_possibilities()
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


func remove_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_TooltipCollision_disable_tooltip(type : String):
	var tooltip
	if type == "transmuting_reagent":
		tooltip = transmuting_reagent_tooltip
	elif type == "upgrading_reagent":
		tooltip = upgrading_reagent_tooltip
	elif type == "upgraded_reagent":
		tooltip = upgraded_reagent_tooltip
	else:
		assert(false, "Not a valid type of tooltip collision: " + str(type))
	
	if tooltip.enabled and tooltips_enabled:
		remove_tooltips()

func _on_TooltipCollision_enable_tooltip(type : String):
	var reagent
	var upgraded
	var tooltip_position
	
	if type == "transmuting_reagent":
		reagent = chosen_reagent_name
		upgraded = chosen_reagent_upgraded
		tooltip_position = $TransmutingReagent/Reagent/TooltipPosition
	elif type == "upgrading_reagent":
		reagent = chosen_reagent_name
		upgraded = false
		tooltip_position = $UpgradingReagent/Reagent/TooltipPosition
	elif type == "upgraded_reagent":
		reagent = chosen_reagent_name
		upgraded = true
		tooltip_position = $UpgradingReagent/ReagentUpgraded/TooltipPosition
	else:
		assert(false, "Not a valid type of tooltip collision: " + str(type))
	
	tooltips_enabled = true
	var tooltip = ReagentManager.get_tooltip(reagent, upgraded, false, false)
	TooltipLayer.add_tooltip(tooltip_position.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, tooltip.subtitle, true)
	tooltip = ReagentManager.get_substitution_tooltip(reagent)
	if tooltip:
		TooltipLayer.add_tooltip(tooltip_position.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, null, false, true, false)
