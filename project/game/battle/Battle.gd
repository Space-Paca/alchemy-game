extends Node2D

onready var effect_manager = $EffectManager
onready var hand = $Hand
onready var reagents = $Reagents
onready var draw_bag = $DrawBag
onready var discard_bag = $DiscardBag
onready var grid = $Grid
onready var pass_turn_button = $PassTurnButton
onready var enemies_node = $Enemies
onready var player_ui = $PlayerUI

const ENEMY_MARGIN = 10

var player


func setup(_player: Player, battle_info: Dictionary):
	setup_nodes()

	setup_player(_player)
	
	setup_player_ui()

	setup_enemy(battle_info)
	
	effect_manager.setup(_player, enemies_node.get_children())

	# For reasons I don't completely understand, Grid needs some time to actually
	# place the slots in the correct position. Without this, all reagents will go
	# to the first slot position.
	yield(get_tree().create_timer(1.0), "timeout")
	new_player_turn()


func setup_nodes():
	draw_bag.hand = hand
	draw_bag.reagents = reagents
	draw_bag.discard_bag = discard_bag
	grid.discard_bag = discard_bag


func setup_player(_player):
	player = _player
	
	#Initial dummy bag
	for _i in range(3):
		draw_bag.add_reagent(ReagentManager.create_object("common"))
	for _i in range(2):
		draw_bag.add_reagent(ReagentManager.create_object("damaging"))
	for _i in range(2):
		draw_bag.add_reagent(ReagentManager.create_object("defensive"))
	
	#Setup player hand
	hand.set_hand(4)
	
	#Setup player grid
	grid.set_grid(2)
	
	player.set_hud(player_ui)

	disable_player()

func setup_player_ui():
	#Centralize grid
	grid.rect_position.x = get_viewport().size.x/2 - grid.get_width()*grid.rect_scale.x/2
	#Centralize hand
	hand.position.x = get_viewport().size.x/2 - hand.get_width()*hand.scale.x/2
	#Fix pass-turn button position
	pass_turn_button.rect_position.x = hand.global_position.x + hand.get_width()*hand.scale.x + 20

func setup_enemy(battle_info):
	#Clean up dummy enemies
	for child in enemies_node.get_children():
		enemies_node.remove_child(child)
		child.queue_free()
	
	for enemy in battle_info.enemies:
		var enemy_node = EnemyManager.create_object(enemy)
		enemies_node.add_child(enemy_node)
		enemy_node.data.connect("acted", self, "_on_enemy_acted")
	
	#Enemy example, remove when battle_info works
	for i in range(2):
		var sk = EnemyManager.create_object("skeleton")
		enemies_node.add_child(sk)
		sk.data.connect("acted", self, "_on_enemy_acted")
	
	#Update enemies positions
	var x = 0
	for enemy in enemies_node.get_children():
		enemy.position.x = x
		x += ENEMY_MARGIN + enemy.get_width()
	
	#Update enemies intent
	for enemy in enemies_node.get_children():
		enemy.update_intent()


func new_player_turn():
	if hand.available_slot_count() > 0:
		draw_bag.refill_hand()
		yield(draw_bag,"hand_refilled")
	
	enable_player()


func new_enemy_turn():
	disable_player()
	if not grid.is_empty():
		grid.clean_grid()
		yield(grid, "cleaned")

	for enemy in enemies_node.get_children():
		enemy.act()
		yield(enemy, "acted")

	new_player_turn()


func disable_player():
	pass_turn_button.disabled = true
	grid.disable()


func enable_player():
	pass_turn_button.disabled = false
	grid.enable()


func apply_effects(effects: Array, effect_args: Array):
	for i in range(effects.size()):
		if effect_manager.has_method(effects[i]):
			effect_manager.callv(effects[i], effect_args[i])
		else:
			print("Effect %s not found" % effects[i])
			assert(false)

func combination_failure():
	pass
	

func _on_enemy_acted(action, args):
	print("heyho ", action)
	if action == "damage":
		player.damage(args.value)

func _on_DiscardBag_reagent_discarded(reagent):
	reagents.remove_child(reagent)


func _on_PassTurnButton_pressed():
	new_enemy_turn()
