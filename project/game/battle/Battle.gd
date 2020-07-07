tool

extends Node2D

signal won
signal finished(is_boss)
signal combination_made(reagent_matrix)
signal current_reagents_updated(curr_reagents)
signal finished_enemies_init
signal combination_rewarded(combination)
signal rewarded_combinations_seen(combinations)
signal grid_modified(reagent_matrix)
signal recipe_book_toggle

onready var effect_manager = $EffectManager
onready var hand = $Hand
onready var reagents = $Reagents
onready var draw_bag = $DrawBag
onready var discard_bag = $DiscardBag
onready var name_holder = $NameHolder
onready var grid = $Grid
onready var pass_turn_button = $PassTurnButton
onready var enemies_node = $Enemies
onready var player_ui = $PlayerUI
onready var recipe_banner = $NameHolder/RecipeBanner
onready var create_recipe_button = $CreateRecipeButton
onready var recipes_button = $RecipesButton
onready var favorites = $Favorites
onready var available_favorites = [$Favorites/FavoriteButton1,
	$Favorites/FavoriteButton2, $Favorites/FavoriteButton3,
	$Favorites/FavoriteButton4, $Favorites/FavoriteButton5,
	$Favorites/FavoriteButton6, $Favorites/FavoriteButton7,
	$Favorites/FavoriteButton8]
onready var targeting_interface = $TargetingInterface

const WINDOW_W = 1920
const WINDOW_H = 1080
const MAX_ENEMIES = 4
const VICTORY_SCENE = preload("res://game/battle/screens/victory/Win.tscn")
const GAMEOVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")

var ended := false
var player_disabled := true
var is_boss
var is_elite
var player
var win_screen
var is_dragging_reagent := false


func _ready():
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("battle_won", self, "_on_Debug_battle_won")


func setup(_player: Player, encounter: Encounter, favorite_combinations: Array):
	setup_nodes()
	
	setup_player(_player)
	
	effect_manager.setup(_player)
	
	setup_favorites(favorite_combinations)
	
	setup_player_ui()
	
	setup_enemy(encounter)
	
	setup_audio(encounter)
	
	setup_win_screen(encounter)
	
	AudioManager.play_sfx("start_battle")
	
	#Wait sometime before starting battle
	yield(get_tree().create_timer(1.0), "timeout")
	
	if enemies_init():
		yield(self, "finished_enemies_init")

	new_player_turn()


func setup_nodes():
	draw_bag.hand = hand
	draw_bag.reagents = reagents
	draw_bag.discard_bag = discard_bag
	grid.discard_bag = discard_bag
	grid.hand = hand


func setup_player(_player):
	player = _player
	
	#Setup player bag
	for bag_reagent in player.bag:
		var reagent = create_reagent(bag_reagent.type)
		if bag_reagent.upgraded:
			reagent.upgrade()
		draw_bag.add_reagent(reagent)
	
	#Setup player hand
	hand.set_hand(player.hand_size)
	
	#Setup player grid
	grid.set_grid(player.grid_size)
	
	player.connect("died", self, "_on_player_died")
	player.connect("draw_reagent", self, "_on_player_draw_reagent")
	
	player.set_hud(player_ui)

	disable_player()


func setup_favorites(favorite_combinations: Array):
	for combination in favorite_combinations:
		add_favorite(combination)


func setup_player_ui():
	# warning-ignore:integer_division
	var ui_center = 2*WINDOW_W/10
	# warning-ignore:integer_division
	var grid_center = 11*WINDOW_H/25
	
	#Position grid
	grid.rect_position.x = ui_center
	grid.rect_position.y = grid_center
	#Position hand
	var hand_margin = 14
	hand.position.x = ui_center
	hand.position.y = grid.rect_position.y + grid.get_height()/2*grid.rect_scale.y + hand_margin
	#Position create-recipe button
	create_recipe_button.rect_position.x = ui_center - create_recipe_button.rect_size.x*create_recipe_button.rect_scale.x/2
	#Position bags
	var bag_margin = 120
	discard_bag.position.x = create_recipe_button.rect_position.x + create_recipe_button.rect_size.x*create_recipe_button.rect_scale.x + bag_margin
	draw_bag.position.x = create_recipe_button.rect_position.x - bag_margin - draw_bag.get_width()*draw_bag.scale.x
	#Position pass-turn button
	var button_margin = 54
	pass_turn_button.rect_position.x = discard_bag.global_position.x + discard_bag.get_width()*discard_bag.scale.x + button_margin
	#Position player ui
	player_ui.position.x = draw_bag.position.x
	player_ui.set_life(player.max_hp, player.hp)
	player_ui.set_gold(player.currency)
	player_ui.set_gems(player.gems)
	player_ui.update_tooltip_pos()
	#Position spell name holder
	name_holder.rect_position.x = player_ui.position.x
	#Position favorites
	favorites.rect_position = Vector2(ui_center, grid_center) - favorites.rect_size / 2


func setup_enemy(encounter: Encounter):
	if encounter.is_boss:
		is_boss = true
	if encounter.is_elite:
		is_elite = true
	
	#Clean up dummy enemies
	for child in enemies_node.get_children():
		enemies_node.remove_child(child)
		child.queue_free()

	for enemy in encounter.enemies:
		add_enemy(enemy)
	
	update_enemy_positions()


func enemies_init():
	var had_init = false
	for enemy in enemies_node.get_children():
		if enemy.data.battle_init:
			had_init = true
			enemy.act()
			yield(enemy, "action_resolved")
			#Wait a bit before next enemy/start player turn
			yield(get_tree().create_timer(.3), "timeout")
	
	emit_signal("finished_enemies_init")
	return had_init


func setup_audio(encounter : Encounter):
	if encounter.is_boss:
		AudioManager.play_bgm("boss1", 3)
	else:
		AudioManager.play_bgm("battle", 3)
	AudioManager.play_ambience("forest")
	player_ui.update_audio(player.hp, player.max_hp)


func setup_win_screen(encounter: Encounter):
	win_screen = VICTORY_SCENE.instance()
	add_child(win_screen)
	win_screen.connect("continue_pressed", self, "_on_win_screen_continue_pressed")
	win_screen.connect("reagent_looted", self, "_on_win_screen_reagent_looted")
	win_screen.connect("reagent_sold", self, "_on_win_screen_reagent_sold")
	win_screen.connect("combinations_seen", self, "_on_win_screen_combinations_seen")
	win_screen.connect("combination_chosen", self, "_on_win_screen_combination_chosen")
	win_screen.connect("gem_collected", self, "_on_win_screen_gem_collected")
	
	win_screen.set_loot(encounter.get_loot())

func create_reagent(type):
	var reagent = ReagentManager.create_object(type)
	reagent.rect_scale = Vector2(.8,.8)
	reagent.connect("started_dragging", self, "_on_reagent_drag")
	reagent.connect("stopped_dragging", self, "_on_reagent_stop_drag")
	reagent.connect("hovering", self, "_on_reagent_hover")
	reagent.connect("stopped_hovering", self, "_on_reagent_stop_hover")
	reagent.connect("quick_place", self, "_on_reagent_quick_place")
	reagent.connect("destroyed", self, "_on_reagent_destroyed")
	return reagent

func add_enemy(enemy, initial_pos = false, just_spawned = false):
	var enemy_node = EnemyManager.create_object(enemy)
	enemies_node.add_child(enemy_node)
	
	if initial_pos:
		enemy_node.position = initial_pos
	else:
		enemy_node.position = $EnemyStartPosition.position
	
	if just_spawned:
		AudioManager.play_enemy_spawn_sfx(enemy_node.data.sfx)
		enemy_node.just_spawned = true
	
	#Idle sfx
	if enemy_node.data.use_idle_sfx:
		AudioManager.play_enemy_idle_sfx(enemy_node.data.sfx)
	
	enemy_node.connect("action", self, "_on_enemy_acted")
	enemy_node.connect("died", self, "_on_enemy_died")
	effect_manager.add_enemy(enemy_node)
	
	enemy_node.update_action()


func update_enemy_positions():
	var enemy_count = enemies_node.get_child_count()
	if enemy_count == 4:
		set_enemy_pos(0, 1)
		set_enemy_pos(1, 2)
		set_enemy_pos(2, 3)
		set_enemy_pos(3, 4)
	elif enemy_count == 3:
		set_enemy_pos(0, 1)
		set_enemy_pos(1, 5)
		set_enemy_pos(2, 3)
	elif enemy_count == 2:
		set_enemy_pos(0, 6)
		set_enemy_pos(1, 7)
	elif enemy_count == 1:
		set_enemy_pos(0, 8)
	else:
		push_error(str(enemy_count) + " is not a valid enemy number")
		assert(false)
	

func new_player_turn():
	if ended:
		return
	
	player.new_turn()
	
	if hand.available_slot_count() > 0:
		draw_bag.refill_hand()
		yield(draw_bag,"hand_refilled")
	
	enable_player()


func new_enemy_turn():
	disable_player()
	if not grid.is_empty():
		grid.return_to_hand()
		yield(grid, "returned_to_hand")

	for enemy in enemies_node.get_children():
		if not enemy.just_spawned:
			enemy.new_turn()
			enemy.act()
			yield(enemy, "acted")
		if ended:
			return
	
	#Resolve enemies spawned in enemy turn
	for enemy in enemies_node.get_children():
		if enemy.just_spawned:
			enemy.just_spawned = false
			if enemy.data.battle_init:
				enemy.act()
				yield(enemy, "action_resolved")
				#Wait a bit before next enemy/start player turn
				yield(get_tree().create_timer(.3), "timeout")

	new_player_turn()


func disable_player():
	draw_bag.disable()
	discard_bag.disable()
	player_disabled = true
	pass_turn_button.disabled = true
	create_recipe_button.disabled = true
	set_favorites_disabled(true)
	
	for reagent in reagents.get_children():
		reagent.disable_dragging()


func enable_player():
	if ended:
		return
	draw_bag.enable()
	discard_bag.enable()
	
	player_disabled = false
	pass_turn_button.disabled = false
	create_recipe_button.disabled = false
	set_favorites_disabled(false)
	
	for reagent in reagents.get_children():
		reagent.enable_dragging()


func set_favorites_disabled(disabled: bool):
	for button in favorites.get_children():
		button.disabled = disabled


func apply_effects(effects: Array, effect_args: Array = [[]], destroy_reagents: Array = [], boost_effects: Dictionary = {}):
	if effects[0] == "combination_failure":
		effect_manager.combination_failure(effect_args, grid)
		yield(effect_manager, "failure_resolved")

	else:
		# Destroy reagents if needed
		for reagent in destroy_reagents:
			if grid.destroy_reagent(reagent):
				yield(grid, "reagent_destroyed")
		
		# Discard reagents
		grid.clean()
		
		# Show targeting interface if needed
		var total_targets = get_targeted_effect_total(effects)
		if total_targets:
			targeting_interface.begin(total_targets)
		
		var used_temp_strength = false
		for i in range(effects.size()):
			if effect_manager.has_method(effects[i]):
				if effects[i] == "damage" or \
				   effects[i] == "damage_all" or \
				   effects[i] == "damage_random" or \
				   effects[i] == "drain":
					used_temp_strength = true
				var args = effect_args[i].duplicate()
				args.append(boost_effects)
				effect_manager.callv(effects[i], args)
				yield(effect_manager, "effect_resolved")
				# Next target
				if total_targets and effects[i] in effect_manager.TARGETED_EFFECTS:
					targeting_interface.next_target()
			else:
				print("Effect %s not found" % effects[i])
				assert(false)
		
		if used_temp_strength:
			player.remove_status("temp_strength")

		if total_targets:
			targeting_interface.end()
	
	enable_player()


func get_targeted_effect_total(effects: Array) -> int:
	if enemies_node.get_children().size() <= 1:
		return 0
	
	var total := 0
	for effect in effects:
		if effect in effect_manager.TARGETED_EFFECTS:
			total += 1
	
	return total


func win():
	for enemy in enemies_node.get_children():
		enemy.disable() #In case of debugging
	for reagent in reagents.get_children():
		reagent.disable()
	
	if is_boss:
		AudioManager.play_sfx("win_boss_battle")
	else:
		AudioManager.play_sfx("win_normal_battle")
	AudioManager.stop_bgm()
	AudioManager.stop_all_enemy_idle_sfx()
	
	ended = true
	
	TooltipLayer.clean_tooltips()
	disable_player()
	player.clear_status()
	emit_signal("won")
	
	#Wait a bit before starting win bgm
	yield(get_tree().create_timer(.3), "timeout")
	if is_boss:
		AudioManager.play_bgm("win_boss_battle", false, true)
	else:
		AudioManager.play_bgm("win_normal_battle", false, true)


func show_victory_screen(combinations: Array):
	win_screen.set_combinations(combinations)
	win_screen.display()


func set_enemy_pos(enemy_idx, pos_idx):
	var enemy = enemies_node.get_child(enemy_idx)
	var target_pos = get_node("EnemiesPositions/Pos"+str(pos_idx))
	enemy.set_pos(target_pos.position)


func autocomplete_grid(combination: Combination):
	var added_reagents := []
	var grid_reagents := []
	
	for slot in grid.slots.get_children():
		if slot.current_reagent:
			grid_reagents.append(slot.current_reagent)
	
	for i in range(combination.grid_size):
		for j in range(combination.grid_size):
			if combination.matrix[i][j]:
				for reagent in reagents.get_children():
					if not added_reagents.has(reagent) and\
							reagent.type == combination.matrix[i][j]:
						if not reagent.slot:
							push_error("reagent isn't in slot")
							assert(false)
						grid.slots.get_child(i * grid.grid_size +\
								j).set_reagent(reagent)
						added_reagents.append(reagent)
						break
	
	for reagent in grid_reagents:
		if not added_reagents.has(reagent):
			if reagent.slot.current_reagent != reagent:
				reagent.slot = null
			hand.place_reagent(reagent)


func unhighlight_reagents():
	for reagent in reagents.get_children():
		reagent.unhighlight()


func has_reagents(reagent_array: Array, highlight: bool = false) -> bool:
	var dup_array : Array = reagent_array.duplicate()
	var selected_reagents := []
	
	for reagent in reagents.get_children():
		for reagent_name in dup_array:
			if reagent_name == reagent.type:
				selected_reagents.append(reagent)
				dup_array.erase(reagent_name)
				break
		if dup_array.empty():
			if highlight:
				for selected_reagent in selected_reagents:
					selected_reagent.highlight()
			return true
	
	return false


func add_favorite(combination: Combination):
	var button : FavoriteButton = available_favorites.pop_front()
	button.set_combination(combination)
	button.visible = true


func remove_favorite(combination: Combination):
	for button in favorites.get_children():
		if button.combination == combination:
			button.set_combination(null)
			button.visible = false
			available_favorites.append(button)


func display_name_for_combination(combination: Combination):
	if combination:
		recipe_banner.text = combination.recipe.name
	else:
		recipe_banner.text = "???" 


func _on_reagent_drag(reagent):
	reagents.move_child(reagent, reagents.get_child_count()-1)
	is_dragging_reagent = true


func _on_reagent_stop_drag(_reagent):
	is_dragging_reagent = false


func _on_reagent_hover(reagent):
	if not is_dragging_reagent:
		reagent.hover_effect()


func _on_reagent_stop_hover(reagent):
	if not is_dragging_reagent:
		reagent.stop_hover_effect()


func _on_reagent_quick_place(reagent):
	if reagent.slot:
		if reagent.slot.type == "grid":
			if hand.available_slot_count() > 0:
				AudioManager.play_sfx("quick_place_hand")
				hand.place_reagent(reagent)
		elif reagent.slot.type == "hand":
			grid.quick_place(reagent)

func _on_reagent_destroyed(reagent):
	player.remove_reagent(reagent.type, reagent.upgraded)

func _on_enemy_acted(enemy, actions):
	for action in actions:
		if ended:
			return
		var name = action[0]
		var args = action[1]
		if name == "damage":
			for i in range(0, args.amount):
				enemy.play_animation("attack")
				var func_state = player.take_damage(enemy, args.value + \
													enemy.get_damage_modifiers(),\
													args.type)
				if i == args.amount - 1:
					enemy.remove_intent()
				#Wait before going to next action/enemy	
				if func_state and func_state.is_valid():
					yield(player, "resolved")
				else:
					yield(get_tree().create_timer(.5), "timeout")
			enemy.remove_status("temp_strength")
		elif name == "shield":
			enemy.gain_shield(args.value)
			enemy.remove_intent()
			#Wait before going to next action/enemy	
			yield(enemy, "resolved")
		elif name == "status":
			if args.target == "self":
				enemy.add_status(args.status, args.value, args.positive)
			elif args.target == "player":
				player.add_status(args.status, args.value, args.positive)
			else:
				push_error("Not a valid target for status effect:" + str(args.target))
				assert(false)
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.5), "timeout")
		elif name == "spawn":
			if enemies_node.get_child_count() < MAX_ENEMIES:
				AnimationManager.play("spawn", enemy.get_center_position())
				add_enemy(args.enemy, enemy.get_center_position(), true)
				update_enemy_positions()
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.6), "timeout")
		elif name == "add_reagent":
			for _i in range(0, args.value):
				AudioManager.play_sfx("create_reagent")
				var reagent = create_reagent(args.type)
				reagents.add_child(reagent)
				randomize()
				var offset = Vector2(rand_range(-10, 10), rand_range(-10, 10))
				reagent.rect_position = enemy.position + offset
				reagent.super_grow()
				yield(get_tree().create_timer(.2), "timeout")
				discard_bag.discard(reagent)
				yield(get_tree().create_timer(.3), "timeout")
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.6), "timeout")
		elif name == "idle":
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.6), "timeout")
	
	enemy.action_resolved()



func _on_enemy_died(enemy):
	enemies_node.remove_child(enemy)
	effect_manager.remove_enemy(enemy)
	
	#Update idle sfx
	if enemy.data.use_idle_sfx:
		var remove_sfx = true
		for other_enemy in enemies_node.get_children():
			if other_enemy.data.use_idle_sfx and other_enemy.data.sfx == enemy.data.sfx:
				remove_sfx = false
				break
		if remove_sfx:
			AudioManager.stop_enemy_idle_sfx(enemy.data.sfx)
	
	if not enemies_node.get_child_count():
		win()


func _on_player_died(_player):
	AudioManager.play_sfx("game_over")
	TooltipLayer.clean_tooltips()
	ended = true
	disable_player()
	for enemy in enemies_node.get_children():
		enemy.disable()
	for reagent in reagents.get_children():
		reagent.disable()
	add_child(GAMEOVER_SCENE.instance())
	AudioManager.play_bgm("gameover", false, true)
	AudioManager.stop_aux_bgm("heart-beat")
	AudioManager.stop_all_enemy_idle_sfx()

func _on_player_draw_reagent(amount):
	draw_bag.draw_reagents(amount)
	yield(draw_bag, "drew_reagents")
	player.draw_reagents_resolve()


func _on_DiscardBag_reagent_discarded(reagent):
	reagents.remove_child(reagent)


func _on_PassTurnButton_pressed():
	new_enemy_turn()


func _on_RecipesButton_pressed():
	emit_signal("recipe_book_toggle")


func _on_win_screen_continue_pressed():
	AudioManager.play_bgm("map")
	emit_signal("finished", is_boss)
	queue_free()


func _on_CreateRecipe_pressed():
	if grid.is_empty():
		AudioManager.play_sfx("error")
		return
		
	
	grid.clear_hint()
	
	var reagent_matrix := []
	var child_index := 0
	var reagent_list = []
	for _i in range(grid.grid_size):
		var line = []
		for _j in range(grid.grid_size):
			var reagent = grid.slots.get_child(child_index).current_reagent
			if reagent:
				reagent_list.append(reagent)
				line.append(reagent.type)
			else:
				line.append(null)
			child_index += 1
		reagent_matrix.append(line)
	
	disable_player()
	
	#Combination animation
	var sfx_dur = AudioManager.get_sfx_duration("combine")
	var dur = reagent_list.size()*.3
	AudioManager.play_sfx("combine", sfx_dur/dur)
	for reagent in reagent_list:
		reagent.combine_animation(grid.get_center(), dur)

	yield(reagent_list.back(), "finished_combine_animation")

	emit_signal("combination_made", reagent_matrix, reagent_list)
	emit_signal("current_reagents_updated", hand.get_reagent_names())


func _on_win_screen_reagent_looted(reagent: String):
	player.add_reagent(reagent, false)


func _on_win_screen_reagent_sold(gold_value: int):
	player.add_currency(gold_value)
	player_ui.set_gold(player.currency)


func _on_win_screen_combinations_seen(rewarded_combinations: Array):
	emit_signal("rewarded_combinations_seen", rewarded_combinations)


func _on_win_screen_combination_chosen(combination: Combination):
	emit_signal("combination_rewarded", combination)


func _on_win_screen_gem_collected(quantity:int):
	player.add_gems(quantity)
	player_ui.set_gems(player.gems)


func _on_Hand_hand_slot_reagent_set():
	var reagent_array = hand.get_reagent_names()
	
	if grid.is_empty():
		emit_signal("current_reagents_updated", reagent_array)
		return
	
	var grid_index = 0
	for i in range(reagent_array.size()):
		if not reagent_array[i]:
			for j in range(grid_index, grid.grid_size * grid.grid_size):
				var reagent = grid.slots.get_child(j).current_reagent
				if reagent:
					grid_index = j + 1
					reagent_array[i] = reagent.type
					break
	
	emit_signal("current_reagents_updated", reagent_array)


func _on_PassTurnButton_mouse_entered():
	if not $PassTurnButton.disabled:
		AudioManager.play_sfx("hover_button")


func _on_CreateRecipeButton_mouse_entered():
	if not $CreateRecipeButton.disabled:
		AudioManager.play_sfx("hover_button")


func _on_RecipesButton_mouse_entered():
	if not $RecipesButton.disabled:
		AudioManager.play_sfx("hover_button")


func _on_CreateRecipeButton_button_down():
	AudioManager.play_sfx("click")


func _on_RecipesButton_button_down():
	AudioManager.play_sfx("click")


func _on_PassTurnButton_button_down():
	AudioManager.play_sfx("click")


func _on_FavoriteButton_pressed(index: int):
	AudioManager.play_sfx("click")
	
	var button : FavoriteButton = favorites.get_child(index)
	if has_reagents(button.reagent_array):
		autocomplete_grid(button.combination)
	else:
		AudioManager.play_sfx("error")


func _on_FavoriteButton_mouse_entered(index: int):
	var button : FavoriteButton = favorites.get_child(index)
# warning-ignore:return_value_discarded
	has_reagents(button.reagent_array, true)


func _on_FavoriteButton_mouse_exited():
	unhighlight_reagents()


func _on_Grid_modified():
	if grid.is_empty():
		recipe_banner.text = ""
		return
	
	var reagent_matrix := []
	for i in range(grid.grid_size):
		var line = []
		for j in range(grid.grid_size):
			var reagent = grid.slots.get_child(grid.grid_size * i + j).current_reagent
			if reagent:
				line.append(reagent.type)
			else:
				line.append(null)
		reagent_matrix.append(line)
	
	emit_signal("grid_modified", reagent_matrix)


func _on_EffectManager_target_set():
	targeting_interface.next_target()


func _on_Debug_battle_won():
	win()
