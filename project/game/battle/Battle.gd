tool

extends Node2D

signal won(is_boss)
signal combination_made(reagent_matrix)

onready var effect_manager = $EffectManager
onready var hand = $Hand
onready var reagents = $Reagents
onready var draw_bag = $DrawBag
onready var discard_bag = $DiscardBag
onready var grid = $Grid
onready var pass_turn_button = $PassTurnButton
onready var enemies_node = $Enemies
onready var player_ui = $PlayerUI
onready var create_recipe_button = $CreateRecipeButton

const ENEMY_MARGIN = 10

var ended = false
var is_boss
var player

func setup(_player: Player, encounter: Encounter):
	setup_nodes()

	setup_player(_player)
	
	setup_player_ui()

	setup_enemy(encounter)
	
	effect_manager.setup(_player, enemies_node.get_children())
	
	setup_audio(encounter)

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
	
	#Setup player bag
	for reagent_type in player.bag:
		var reagent = ReagentManager.create_object(reagent_type)
		reagent.connect("started_dragging", self, "_on_reagent_drag")
		draw_bag.add_reagent(reagent)
	
	#Setup player hand
	hand.set_hand(player.hand_size)
	
	#Setup player grid
	grid.set_grid(player.grid_size)
	
	player.connect("died", self, "_on_player_died")
	
	player.set_hud(player_ui)

	disable_player()


func setup_player_ui():
	var ui_center = 2*get_viewport().size.x/10
	#Position grid
	grid.rect_position.x = ui_center - grid.get_width()*grid.rect_scale.x/2
	grid.rect_position.y = 2*get_viewport().size.x/9 - grid.get_height()*grid.rect_scale.y/2
	#Position hand
	hand.position.x = ui_center - hand.get_width()*hand.scale.x/2
	hand.position.y = grid.rect_position.y + grid.get_height()*grid.rect_scale.y + 20
	#Position create-recipe button
	create_recipe_button.rect_position.x = ui_center - create_recipe_button.rect_size.x*create_recipe_button.rect_scale.x/2
	#Position bags
	var bag_margin = 10
	discard_bag.position.x = create_recipe_button.rect_position.x + create_recipe_button.rect_size.x*create_recipe_button.rect_scale.x + bag_margin
	draw_bag.position.x = create_recipe_button.rect_position.x - bag_margin - draw_bag.get_width()*draw_bag.scale.x
	#Position pass-turn button
	var button_margin = 15
	pass_turn_button.rect_position.x = discard_bag.global_position.x + discard_bag.get_width()*discard_bag.scale.x + button_margin
	
	player_ui.set_life(player.max_hp, player.hp)

func setup_enemy(encounter: Encounter):
	if encounter.is_boss:
		is_boss = true
	
	#Clean up dummy enemies
	for child in enemies_node.get_children():
		enemies_node.remove_child(child)
		child.queue_free()
	
	for enemy in encounter.enemies:
		var enemy_node = EnemyManager.create_object(enemy)
		enemies_node.add_child(enemy_node)
		enemy_node.data.connect("acted", self, "_on_enemy_acted")
		enemy_node.connect("died", self, "_on_enemy_died")
	
	#Update enemies positions
	var x = 0
	for enemy in enemies_node.get_children():
		enemy.position.x = x
		x += ENEMY_MARGIN + enemy.get_width()
	
	#Update enemies intent
	for enemy in enemies_node.get_children():
		enemy.update_intent()

func setup_audio(encounter : Encounter):
	if encounter.is_boss:
		AudioManager.play_bgm("boss1", 3)
	else:
		AudioManager.play_bgm("battle", 3)
	player_ui.update_audio()

func new_player_turn():
	if ended:
		return
	
	player.update_status()
	
	if hand.available_slot_count() > 0:
		draw_bag.refill_hand()
		yield(draw_bag,"hand_refilled")
	
	enable_player()


func new_enemy_turn():
	disable_player()
	if not grid.is_empty():
		grid.clean()
		yield(grid, "cleaned")

	for enemy in enemies_node.get_children():
		enemy.update_status()
		enemy.act()
		yield(enemy, "acted")

	new_player_turn()


func disable_player():
	pass_turn_button.disabled = true
	create_recipe_button.disabled = true
	
	for reagent in reagents.get_children():
		reagent.disable_dragging()


func enable_player():
	if ended:
		return
	
	pass_turn_button.disabled = false
	create_recipe_button.disabled = false
	
	for reagent in reagents.get_children():
		reagent.enable_dragging()


func apply_effects(effects: Array, effect_args: Array = [[]]):
	for i in range(effects.size()):
		if effect_manager.has_method(effects[i]):
			effect_manager.callv(effects[i], effect_args[i])
			yield(effect_manager, "effect_resolved")
		else:
			print("Effect %s not found" % effects[i])
			assert(false)
	
	grid.clean()
	enable_player()


func win():
	ended = true
	disable_player()
	var win_screen = load("res://game/battle/screens/Win.tscn").instance()
	add_child(win_screen)
	win_screen.connect("continue_pressed", self, "_on_win_screen_continue_pressed")


func _on_reagent_drag(reagent):
	reagents.move_child(reagent, reagents.get_child_count()-1)


func _on_enemy_acted(action, args):
	if action == "damage":
		player.take_damage(args.value)
	elif action == "shield":
		args.target.gain_shield(args.value)


func _on_enemy_died(enemy):
	enemies_node.remove_child(enemy)
	effect_manager.remove_enemy(enemy)
	
	if not enemies_node.get_child_count():
		win()


func _on_player_died(_player):
	print("GAME OVER")
	ended = true
	disable_player()
	add_child(load("res://game/battle/screens/GameOver.tscn").instance())


func _on_DiscardBag_reagent_discarded(reagent):
	reagents.remove_child(reagent)


func _on_PassTurnButton_pressed():
	new_enemy_turn()

func _on_win_screen_continue_pressed():
	AudioManager.play_bgm("map")
	emit_signal("won", is_boss)
	queue_free()


func _on_CreateRecipe_pressed():
	if grid.is_empty():
		return
	
	var reagent_matrix := []
	var child_index := 0
	for _i in range(grid.size):
		var line = []
		for _j in range(grid.size):
			var reagent = grid.container.get_child(child_index).current_reagent
			if reagent:
				line.append(reagent.type)
			else:
				line.append(null)
			child_index += 1
		reagent_matrix.append(line)
	
	disable_player()
	emit_signal("combination_made", reagent_matrix)

