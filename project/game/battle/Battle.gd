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
const VICTORY_SCENE = preload("res://game/battle/screens/victory/Win.tscn")
const GAMEOVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")

var ended := false
var is_boss
var player
var loot : Array


func setup(_player: Player, encounter: Encounter):
	setup_nodes()
	
	setup_player(_player)
	
	setup_player_ui()
	
	setup_enemy(encounter)
	
	effect_manager.setup(_player, enemies_node.get_children())
	
	setup_audio(encounter)
	
	loot = encounter.get_loot()
	
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
		reagent.rect_scale = Vector2(.8,.8)
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
	var grid_side = grid.get_height()
	var ui_center = 2*get_viewport().size.x/10
	var grid_center = 5*get_viewport().size.y/12
	
	#Position grid
	#NOTE: For some reason, moving the grid changes the scale of the gridslot y value,
	#and that messes up grid height and width getters. Storing value above to avoid this
	#but when we ahve time, should inspect if this is our problem or an engine's.
	grid.rect_position.x = ui_center - grid_side*grid.rect_scale.x/2
	grid.rect_position.y = grid_center - grid_side*grid.rect_scale.y/2
	#Position hand
	var hand_margin = 20
	hand.position.x = ui_center - hand.get_width()*hand.scale.x/2
	hand.position.y = grid.rect_position.y + grid_side*grid.rect_scale.y + hand_margin
	#Position create-recipe button
	create_recipe_button.rect_position.x = ui_center - create_recipe_button.rect_size.x*create_recipe_button.rect_scale.x/2
	#Position bags
	var bag_margin = 40
	discard_bag.position.x = create_recipe_button.rect_position.x + create_recipe_button.rect_size.x*create_recipe_button.rect_scale.x + bag_margin
	draw_bag.position.x = create_recipe_button.rect_position.x - bag_margin - draw_bag.get_width()*draw_bag.scale.x
	#Position pass-turn button
	var button_margin = 15
	pass_turn_button.rect_position.x = discard_bag.global_position.x + discard_bag.get_width()*discard_bag.scale.x + button_margin
	#Position player ui
	player_ui.position.x = draw_bag.position.x
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
	var enemy_count = enemies_node.get_child_count()
	if enemy_count == 4:
		set_enemy_pos(0, 1)
		set_enemy_pos(1, 2)
		set_enemy_pos(2, 3)
		set_enemy_pos(3, 4)
	elif enemy_count == 3:
		set_enemy_pos(0, 1)
		set_enemy_pos(1, 3)
		set_enemy_pos(2, 5)
	elif enemy_count == 2:
		set_enemy_pos(0, 6)
		set_enemy_pos(1, 7)
	elif enemy_count == 1:
		set_enemy_pos(0, 8)
	else:
		print(enemy_count, " is not a valid enemy number")
		assert(false)
		
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
	var win_screen = VICTORY_SCENE.instance()
	add_child(win_screen)
	win_screen.connect("continue_pressed", self, "_on_win_screen_continue_pressed")
	win_screen.connect("reagent_looted", self, "_on_win_screen_reagent_looted")
	win_screen.set_loot(loot)


func set_enemy_pos(enemy_idx, pos_idx):
	var enemy = enemies_node.get_child(enemy_idx)
	var target_pos = get_node("EnemiesPositions/Pos"+str(pos_idx))
	enemy.global_position.x = target_pos.position.x - enemy.get_width() 
	enemy.global_position.y = target_pos.position.y - enemy.get_height()


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
	add_child(GAMEOVER_SCENE.instance())


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
	for _i in range(grid.grid_size):
		var line = []
		for _j in range(grid.grid_size):
			var reagent = grid.container.get_child(child_index).current_reagent
			if reagent:
				line.append(reagent.type)
			else:
				line.append(null)
			child_index += 1
		reagent_matrix.append(line)
	
	disable_player()
	emit_signal("combination_made", reagent_matrix)


func _on_win_screen_reagent_looted(reagent: String):
	player.add_reagent(reagent)
