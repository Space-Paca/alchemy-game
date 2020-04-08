extends Node

onready var effect_manager = $EffectManager
onready var Hand = $Hand
onready var Reagents = $Reagents
onready var DrawBag = $DrawBag
onready var DiscardBag = $DiscardBag
onready var Grid = $Grid
onready var PassTurn = $PassTurnButton
onready var PlayerUI = $PlayerUI

const ENEMY_MARGIN = 10

var enemies
var player


func setup(player: Player, battle_info: Dictionary):
	setup_nodes()

	setup_player(player)

	setup_enemy(battle_info)
	
	effect_manager.setup(player, enemies)

	# For reasons I don't completely understand, Grid needs some time to actually
	# place the slots in the correct position. Without this, all reagents will go
	# to the first slot position.
	yield(get_tree().create_timer(1.0), "timeout")
	new_player_turn()


func setup_nodes():
	DrawBag.Hand = Hand
	DrawBag.Reagents = Reagents
	DrawBag.DiscardBag = DiscardBag
	Grid.discard_bag = DiscardBag
	#DiscardBag.Reagents = Reagents
	PassTurn.Battle = self


func setup_player(_player):
	player = _player
	
	#Initial dummy bag
	for _i in range(12):
		var type = ReagentManager.random_type()
		DrawBag.add_reagent(ReagentManager.create_object(type))

	disable_player()


func setup_enemy(battle_info):
	#Clean up dummy enemies
	for child in $Enemies.get_children():
		$Enemies.remove_child(child)
		child.queue_free()
	
	for enemy in battle_info.enemies:
		$Enemies.add_child(EnemyManager.create_object(enemy))
	
	#Enemy example, remove when battle_info works
	$Enemies.add_child(EnemyManager.create_object("skeleton"))
	$Enemies.add_child(EnemyManager.create_object("skeleton"))
	enemies = $Enemies.get_children()

	#Update enemies positions
	var x = 0
	for enemy in $Enemies.get_children():
		enemy.position.x = x
		x += ENEMY_MARGIN + enemy.get_width()
	
	#Update enemies intent
	for enemy in $Enemies.get_children():
		enemy.update_intent()


func new_player_turn():
	if Hand.available_slot_count() > 0:
		DrawBag.refill_hand()
		yield(DrawBag,"hand_refilled")

	enable_player()


func new_enemy_turn():
	disable_player()
	if not Grid.is_empty():
		Grid.clean_grid()
		yield(Grid, "cleaned")

	for enemy in $Enemies.get_children():
		enemy.act()
		yield(enemy, "acted")

	new_player_turn()


func disable_player():
	PassTurn.disabled = true
	Grid.disable()


func enable_player():
	PassTurn.disabled = false
	Grid.enable()


func apply_effects(effects: Array, effect_args: Array):
	for i in range(effects.size()):
		if effect_manager.has_method(effects[i]):
			effect_manager.callv(effects[i], effect_args[i])
		else:
			print("Effect %s not found" % effects[i])
			assert(false)


func combination_failure():
	pass


func _on_DiscardBag_reagent_discarded(reagent):
	Reagents.remove_child(reagent)


func _on_EffectManager_target_required(function_state):# GDScriptFunctionState):
	print(function_state)
#	function_state.resume()
