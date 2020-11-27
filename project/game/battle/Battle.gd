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
signal hand_set
signal update_recipes_display

onready var effect_manager = $EffectManager
onready var book = $Book
onready var hand = $Book/Hand
onready var reagents = $Reagents
onready var draw_bag = $Book/DrawBag
onready var discard_bag = $Book/DiscardBag
onready var grid = $Book/Grid
onready var pass_turn_button = $Book/PassTurnButton
onready var enemies_node = $Enemies
onready var player_ui = $Book/PlayerUI
onready var recipe_name_display = $Book/RecipeNameDisplay
onready var combine_button = $Book/CombineButton
onready var recipes_button = $Book/RecipesButton
onready var favorites = $Book/Favorites
onready var targeting_interface = $TargetingInterface

export(Array, Texture) var backgrounds
export(Array, Texture) var foregrounds
export(Array, Texture) var boss_backgrounds
export(Array, Texture) var boss_foregrounds

const WINDOW_W = 1920
const WINDOW_H = 1080
const MAX_ENEMIES = 4
const VICTORY_SCENE = preload("res://game/battle/screens/victory/Win.tscn")
const GAMEOVER_SCENE = preload("res://game/battle/screens/game-over/GameOver.tscn")
const BG_ENTER_DUR = .7
const FG_ENTER_DUR = 1.0
const BOOK_ENTER_DUR = .4
const BOOK_START_X = -1920
const BOOK_TARGET_X = -812 

var floor_level
var ended := false
var player_disabled := true
var is_boss
var is_elite
var player
var win_screen
var deviated_recipes
var is_dragging_reagent := false
var recipes_created
var current_encounter
var first_turn = true


func _ready():
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("battle_won", self, "_on_Debug_battle_won")


func setup(_player: Player, encounter: Encounter, favorite_combinations: Array, _floor_level: int):
	floor_level = _floor_level
	current_encounter = encounter
	
	setup_bg()
	
	setup_nodes(_player)
	
	setup_player(_player)
	
	effect_manager.setup(_player)
	
	setup_favorites(favorite_combinations)
	
	setup_player_ui()
	
	setup_enemy(encounter)
	
	setup_audio(encounter)
	
	AudioManager.play_sfx("start_battle")
	
	#Wait sometime before showing book and starting battle
	yield(get_tree().create_timer(BG_ENTER_DUR + 1.0), "timeout")
	
	$BGTween.interpolate_property(book, "rect_position:x", BOOK_START_X, BOOK_TARGET_X, BOOK_ENTER_DUR, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$BGTween.start()
	
	yield($BGTween, "tween_completed")
	
	if enemies_init():
		yield(self, "finished_enemies_init")
	
	player.call_artifacts("battle_start", {"player": player})
	if encounter.is_elite and player.has_artifact("vulture_mask"):
		player.add_status("perm_strength", 5, true)
	
	new_player_turn()


func setup_bg():
	book.rect_position.x = BOOK_START_X
	
	if current_encounter.is_boss:
		if floor_level == 3:
			$FinalBossBG.show()
		$BG.texture = boss_backgrounds[floor_level-1]
		$FG.texture = boss_foregrounds[floor_level-1]
	else:
		$BG.texture = backgrounds[floor_level-1]
		$FG.texture = foregrounds[floor_level-1]
	
	$BGTween.interpolate_property($BG, "rect_position:x", 0, -499, BG_ENTER_DUR, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$BGTween.interpolate_property($FG, "rect_position:x", 150, -499, FG_ENTER_DUR, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$BGTween.start()

func setup_nodes(_player):
	draw_bag.player = _player
	draw_bag.hand = hand
	draw_bag.reagents = reagents
	draw_bag.discard_bag = discard_bag
	discard_bag.player = _player
	discard_bag.connect("reagent_exploded", self, "damage_player")
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
	player.connect("freeze_hand", self, "_on_player_freeze_hand")
	player.connect("restrict", self, "_on_player_restrict")
	
	player.set_hud(player_ui)

	disable_player()


func setup_favorites(favorite_combinations: Array):
	for combination in favorite_combinations:
		add_favorite(combination)


func setup_player_ui():
	player_ui.set_life(player.max_hp, player.hp)
	
	player_ui.update_portrait(player.hp, player.max_hp)
	
	player_ui.update_artifacts(player)

func setup_enemy(encounter: Encounter):
	if encounter.is_boss:
		is_boss = true
	if encounter.is_elite:
		is_elite = true
	
	#Clean up dummy enemies
	for child in enemies_node.get_children():
		enemies_node.remove_child(child)
		child.queue_free()
	
	#Wait for BG to start placing enemies
	yield($BGTween, "tween_completed")
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
		AudioManager.play_bgm("battle" + str(floor_level), 3)
	AudioManager.play_ambience("forest")
	player_ui.update_audio(player.hp, player.max_hp)


func setup_win_screen(encounter: Encounter):
	win_screen = VICTORY_SCENE.instance()
	add_child(win_screen)
	win_screen.setup(player)
	win_screen.connect("continue_pressed", self, "_on_win_screen_continue_pressed")
	win_screen.connect("reagent_looted", self, "_on_win_screen_reagent_looted")
	win_screen.connect("artifact_looted", self, "_on_win_screen_artifact_looted")
	win_screen.connect("reagent_sold", self, "_on_win_screen_reagent_sold")
	win_screen.connect("combinations_seen", self, "_on_win_screen_combinations_seen")
	win_screen.connect("combination_chosen", self, "_on_win_screen_combination_chosen")
	win_screen.connect("pearl_collected", self, "_on_win_screen_pearl_collected")
	
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
	reagent.connect("unrestrained_slot", self, "_on_reagent_unrestrained_slot")
	return reagent


func add_enemy(enemy, initial_pos = false, just_spawned = false, is_minion = false):
	var enemy_node = EnemyManager.create_object(enemy, player)
	enemies_node.add_child(enemy_node)
	
	if is_minion:
		enemy_node.add_status("minion", 1, false)
	
	if initial_pos:
		enemy_node.position = initial_pos
	else:
		enemy_node.position = $EnemyStartPosition.position
	
	if just_spawned:
		enemy_node.just_spawned = true
	
	#Idle sfx
	if enemy_node.data.use_idle_sfx:
		AudioManager.play_enemy_idle_sfx(enemy_node.data.sfx)
	
	enemy_node.connect("action", self, "_on_enemy_acted")
	enemy_node.connect("died", self, "_on_enemy_died")
	enemy_node.connect("spawn_new_enemy", self, "spawn_new_enemy")
	enemy_node.connect("damage_player", self, "damage_player")
	enemy_node.connect("add_status_all_enemies", self, "add_status_all_enemies")
	effect_manager.add_enemy(enemy_node)
	
	if just_spawned:
		AudioManager.play_enemy_spawn_sfx(enemy_node.data.sfx)
	else:
		randomize()
		yield(get_tree().create_timer(rand_range(.3, .4)), "timeout")
		AudioManager.play_enemy_spawn_sfx(enemy_node.data.sfx)
	
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
	
	recipes_created = 0
	deviated_recipes = []
	player.new_turn()
	
	if hand.available_slot_count() > 0:
		draw_bag.refill_hand()
		yield(draw_bag,"hand_refilled")
		emit_signal("update_recipes_display")
	
	if player.get_status("burning"):
		hand.burn_reagents(player.get_status("burning").amount)
	
	if player.get_status("confusion"):
		var func_state = hand.randomize_reagents()
		if func_state and func_state.is_valid():
			yield(hand, "reagents_randomized")
	
	if player.get_status("restrain"):
		var func_state = grid.restrain(player.get_status("restrain").amount)
		if func_state and func_state.is_valid():
			yield(grid, "restrained")
	
	
	enable_player()
	
	if (first_turn):
		first_turn = false
		emit_signal("hand_set")


func new_enemy_turn():
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
	#and trigger end turn status
	for enemy in enemies_node.get_children():
		if enemy.just_spawned:
			enemy.just_spawned = false
			if enemy.data.battle_init:
				enemy.act()
				yield(enemy, "action_resolved")
				#Wait a bit before next enemy/start player turn
				yield(get_tree().create_timer(.3), "timeout")
		enemy.update_status("end_turn")
	
	new_player_turn()


func disable_player():
	draw_bag.disable()
	discard_bag.disable()
	player_disabled = true
	pass_turn_button.disabled = true
	combine_button.disable()
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
	
	#Check curse
	var curse = player.get_status("curse")
	if curse:
		combine_button.enable_curse()
		combine_button.set_curse(recipes_created, curse.amount)
	else:
		combine_button.disable_curse()

	if not curse or curse.amount > recipes_created:
		combine_button.enable()
	

		
	
	set_favorites_disabled(false)
	
	for reagent in reagents.get_children():
		reagent.enable_dragging()


func recipe_book_toggled(visible: bool):
	if visible:
		recipes_button.hide()
		pass_turn_button.hide()
		player_ui.disable_tooltips()
		TooltipLayer.clean_tooltips()
		for reagent in reagents.get_children():
			reagent.disable()
			reagent.disable_dragging()
		draw_bag.disable()
		discard_bag.disable()
		grid.hide_effects()
		hand.hide_effects()
	else:
		player_ui.enable_tooltips()
		recipes_button.show()
		pass_turn_button.show()
		for reagent in reagents.get_children():
			reagent.enable()
			reagent.enable_dragging()
		draw_bag.enable()
		discard_bag.disable()
		grid.show_effects()
		hand.show_effects()


func set_favorites_disabled(disabled: bool):
	for button in favorites.get_children():
		if disabled:
			button.disable()
		else:
			button.enable()


func add_recipe_deviation(name):
	if player.get_status("deviation"):
		deviated_recipes.append(name)


func apply_effects(effects: Array, effect_args: Array = [[]],
		destroy_reagents: Array = [], boost_effects: Dictionary = {}):
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
	
	#Resolve enemies spawned in player turn
	for enemy in enemies_node.get_children():
		if enemy.just_spawned:
			enemy.just_spawned = false
			if enemy.data.battle_init:
				enemy.act()
				yield(enemy, "action_resolved")
				#Wait a bit before next enemy/start player turn
				yield(get_tree().create_timer(.3), "timeout")
	
	enable_player()


func get_targeted_effect_total(effects: Array) -> int:
	if enemies_node.get_children().size() <= 1:
		return 0
	
	var total := 0
	for effect in effects:
		if effect in effect_manager.TARGETED_EFFECTS:
			total += 1
	
	return total


func disable_elements():
	for enemy in enemies_node.get_children():
		enemy.disable()
	for reagent in reagents.get_children():
		reagent.disable()


func enable_elements():
	for enemy in enemies_node.get_children():
		enemy.enable()
	for reagent in reagents.get_children():
		reagent.enable()


func win():
	if ended:
		return
	
	ended = true
	disable_elements()
	
	if is_boss:
		AudioManager.play_sfx("win_boss_battle")
	else:
		AudioManager.play_sfx("win_normal_battle")
	AudioManager.stop_bgm()
	AudioManager.stop_all_enemy_idle_sfx()
	
	if not is_boss or floor_level < Debug.MAX_FLOOR:
		setup_win_screen(current_encounter)
		
		TooltipLayer.clean_tooltips()
		disable_player()
		player.clear_status()
		
		player.call_artifacts("battle_finish", {"player": player})
		
		emit_signal("won")
		
		#Wait a bit before starting win bgm
		yield(get_tree().create_timer(.3), "timeout")
		if is_boss:
			AudioManager.play_bgm("win_boss_battle", false, true)
		else:
			AudioManager.play_bgm("win_normal_battle", false, true)
	
	else:
		_on_win_screen_continue_pressed()


func show_victory_screen(combinations: Array):
	win_screen.set_combinations(combinations)
	win_screen.display()


func set_enemy_pos(enemy_idx, pos_idx):
	var enemy = enemies_node.get_child(enemy_idx)
	var target_pos = get_node("EnemiesPositions/Pos"+str(pos_idx))
	enemy.set_pos(target_pos.position)


func autocomplete_grid(combination: Combination):
	for slot in grid.slots.get_children():
		if slot.current_reagent:
			hand.place_reagent(slot.current_reagent)

	var recipe_reagents = combination.recipe.reagents.duplicate()
	var available_reagents := []
	for reagent in reagents.get_children():
		available_reagents.append(reagent.type)
	var selected_reagents = ReagentManager.get_reagents_to_use(recipe_reagents, available_reagents)
	
	if selected_reagents:
		for off_i in range(0, grid.grid_size - combination.grid_size + 1):
			for off_j in range(0, grid.grid_size - combination.grid_size + 1):
			
				var valid_hint = true
				for i in range(combination.grid_size):
					for j in range(combination.grid_size):
						if combination.matrix[i][j]:
							var slot = grid.slots.get_child((i+off_i) * grid.grid_size + (j+off_j))
							if slot.is_restrained() or slot.is_restricted():
								valid_hint = false
								#Return already placed reagents to hand
								for gridslot in grid.slots.get_children():
									if gridslot.current_reagent:
										hand.place_reagent(gridslot.current_reagent)
								break
					if not valid_hint:
						break
				#Found valid offset
				if valid_hint:
					for i in range(combination.grid_size):
						for j in range(combination.grid_size):
							if combination.matrix[i][j]:
								var slot = grid.slots.get_child((i+off_i) * grid.grid_size + (j+off_j))
								for idx in selected_reagents.size():
									if selected_reagents[idx] and selected_reagents[idx] == combination.matrix[i][j]:
										selected_reagents[idx] = false
										var reagent = reagents.get_child(idx)
										if not reagent.slot:
											push_error("reagent isn't in slot")
											assert(false)
										if reagent.is_burned():
											reagent.unburn()
											AudioManager.play_sfx("fire_reagent")
											player.take_damage(player, 4, "regular", false)
										slot.set_reagent(reagent)
										break
					return true
	return false


func unhighlight_reagents():
	for reagent in reagents.get_children():
		reagent.unhighlight()


func has_reagents(reagent_array: Array):
	var available_reagents := []
	for reagent in reagents.get_children():
		available_reagents.append(reagent.type)
	var valid_reagents = ReagentManager.get_reagents_to_use(reagent_array, available_reagents)
	if valid_reagents:
		var selected_reagents := []
		for idx in valid_reagents.size():
			if valid_reagents[idx]:
				selected_reagents.append(reagents.get_child(idx))
		return selected_reagents
	
	return false


func add_favorite(combination: Combination):
	for button in favorites.get_children():
		if not button.combination:
			button.set_combination(combination)
			button.show_button()
			break


func remove_favorite(combination: Combination):
	for button in favorites.get_children():
		if button.combination == combination:
			button.set_combination(null)
			button.hide_button()


func display_name_for_combination(combination):
	recipe_name_display.display_name_for_combination(combination)


func spawn_new_enemy(origin: Enemy, new_enemy: String, is_minion:= false):
	if enemies_node.get_child_count()  < MAX_ENEMIES:
		AnimationManager.play("spawn", origin.get_center_position())
		add_enemy(new_enemy, origin.get_center_position(), true, is_minion)
		update_enemy_positions()


func damage_player(source, value, type, use_modifiers:= true):
	var mod = source.get_damage_modifiers() if use_modifiers else 0
	var amount = value + mod
	player.take_damage(source, amount, type)


func add_status_all_enemies(status, amount, positive, extra_args = {}):
	for enemy in enemies_node.get_children():
		enemy.add_status(status, amount, positive, extra_args)


func _on_reagent_drag(reagent):
	reagents.move_child(reagent, reagents.get_child_count()-1)
	is_dragging_reagent = true
	if reagent.is_burned():
		reagent.unburn()
		AudioManager.play_sfx("fire_reagent")
		player.take_damage(player, 4, "regular", false)


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
		if reagent.is_burned():
			reagent.unburn()
			AudioManager.play_sfx("fire_reagent")
			player.take_damage(player, 4, "regular", false)
		if reagent.slot.type == "grid":
			if hand.available_slot_count() > 0:
				AudioManager.play_sfx("quick_place_hand")
				hand.place_reagent(reagent)
		elif reagent.slot.type == "hand":
			grid.quick_place(reagent)


func _on_reagent_destroyed(reagent):
	player.remove_reagent(reagent.type, reagent.upgraded)

func _on_reagent_unrestrained_slot(reagent, slot):
	slot.unrestrain()
	discard_bag.discard(reagent)

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
				if args.amount > 1 and i != args.amount - 1:
					yield(get_tree().create_timer(.8/args.amount), "timeout")
				elif func_state and func_state.is_valid():
					yield(player, "resolved")
				else:
					yield(get_tree().create_timer(.5), "timeout")
		
			enemy.remove_status("temp_strength")
		if name == "drain":
			for i in range(0, args.amount):
				enemy.play_animation("drain")
				var func_state = player.drain(enemy, args.value + \
											  enemy.get_damage_modifiers())
				if i == args.amount - 1:
					enemy.remove_intent()
				#Wait before going to next action/enemy	
				if func_state and func_state.is_valid():
					yield(player, "resolved")
				else:
					yield(get_tree().create_timer(.5), "timeout")
			enemy.remove_status("temp_strength")
		if name == "self_destruct":
			#enemy.play_animation("self_destruct")
			enemy.take_damage(enemy, enemy.hp, "piercing")
			yield(get_tree().create_timer(.1), "timeout")
			
			var func_state = player.take_damage(enemy, args.value +\
					enemy.get_damage_modifiers(), "piercing")
			#Wait before going to next action/enemy
			if func_state and func_state.is_valid():
				yield(player, "resolved")
			else:
				yield(get_tree().create_timer(.5), "timeout")
			
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.5), "timeout")
		elif name == "shield":
			enemy.gain_shield(args.value)
			enemy.remove_intent()
			#Wait before going to next action/enemy	
			yield(enemy, "resolved")
		elif name == "status":
			var value = args.value if args.has("value") else 1
			var reduce = args.reduce if args.has("reduce") else false
			var extra_args = args.extra_args if args.has("extra_args") else {}
			if args.target == "self":
				if not reduce:
					enemy.add_status(args.status, value, args.positive, extra_args)
				else:
					enemy.reduce_status(args.status, value)
					AudioManager.play_sfx("debuff_denied")
			elif args.target == "player":
				if not reduce:
					player.add_status(args.status, value, args.positive, extra_args)
				else:
					player.reduce_status(args.status, value)
					AudioManager.play_sfx("debuff_denied")
			else:
				push_error("Not a valid target for status effect:" + str(args.target))
				assert(false)
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.5), "timeout")
		elif name == "heal":
			var value = args.value
			if args.target == "self":
				var func_state = enemy.heal(value)
				if func_state and func_state.is_valid():
					yield(enemy, "resolved")
				else:
					yield(get_tree().create_timer(.5), "timeout")
			elif args.target == "all_enemies":
				for e in enemies_node.get_children():
					e.heal(value)
					yield(get_tree().create_timer(.5), "timeout")
			else:
				push_error("Not a valid target for heal effect:" + str(args.target))
				assert(false)
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.5), "timeout")
		elif name == "spawn":
			var minion = args.has("minion")
			spawn_new_enemy(enemy, args.enemy, minion)
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.6), "timeout")
		elif name == "add_reagent":
			for _i in range(0, args.value):
				AudioManager.play_sfx("create_trash_reagent")
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
			emit_signal("update_recipes_display")
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.6), "timeout")
		elif name == "idle":
			if args.has("sfx"):
				AudioManager.play_sfx(args.sfx)
			
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			yield(get_tree().create_timer(.6), "timeout")
	
	enemy.action_resolved()


func _on_enemy_died(enemy):
	if ended:
		return
	enemies_node.remove_child(enemy)
	effect_manager.remove_enemy(enemy)
	#Temporary store enemy
	$EnemyToBeRemoved.add_child(enemy)
	
	var func_state = enemy.update_status("on_death")
	if func_state and func_state.is_valid():
		yield(enemy, "finished_updating_status")
	
	for ally_enemy in enemies_node.get_children():
		func_state = ally_enemy.update_status("on_ally_died")
		if func_state and func_state.is_valid():
			yield(ally_enemy, "finished_updating_status")
	
	if enemy.data.change_phase:
		yield(get_tree().create_timer(1.5), "timeout")
		#TODO: Add more cool effects here, like screen shaking
		spawn_new_enemy(enemy, enemy.data.change_phase, false)
	
	$EnemyToBeRemoved.remove_child(enemy)
	
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
		return
	
	#Check for minion enemies and kill if they are the only ones left
	var all_minions = true
	for enemy in enemies_node.get_children():
		if not enemy.get_status("minion"):
			all_minions = false
			break
	if all_minions:
		for enemy in enemies_node.get_children():
			if enemy.get_status("minion"):
				enemy.die()


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
	emit_signal("update_recipes_display")


func _on_player_freeze_hand(amount: int):
	hand.freeze_slots(amount)


func _on_player_restrict(amount: int, type: String):
	grid.restrict(amount, type)


func _on_DiscardBag_reagent_discarded(reagent):
	reagents.remove_child(reagent)


func _on_PassTurnButton_pressed():
	player.update_status("end_turn")
	
	disable_player()
	
	#Check for unstable reagents
	for reagent in reagents.get_children():
		if reagent.unstable:
			reagent.slot.remove_reagent()
			discard_bag.discard(reagent)
			yield(get_tree().create_timer(.5), "timeout")
	
	#clear hints
	grid.clear_hints()
	#Unfreeze hand
	hand.unfreeze_all_slots()
	#Unrestrict grid
	grid.unrestrict_all_slots()
	#Unrestrain grid
	grid.unrestrain_all_slots()
	#Unburn reagents
	hand.unburn_reagents()
	
	new_enemy_turn()


func _on_RecipesButton_pressed():
	emit_signal("recipe_book_toggle")


func _on_win_screen_continue_pressed():
	AudioManager.play_bgm("map" + str(floor_level))
	emit_signal("finished", is_boss)
	queue_free()

func _on_win_screen_reagent_looted(reagent: String):
	player.add_reagent(reagent, false)


func _on_win_screen_artifact_looted(artifact: String):
	player.add_artifact(artifact)


func _on_win_screen_reagent_sold(gold_value: int):
	player.add_gold(gold_value)


func _on_win_screen_combinations_seen(rewarded_combinations: Array):
	emit_signal("rewarded_combinations_seen", rewarded_combinations)


func _on_win_screen_combination_chosen(combination: Combination):
	emit_signal("combination_rewarded", combination)


func _on_win_screen_pearl_collected(quantity:int):
	player.add_pearls(quantity)


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
	if not pass_turn_button.disabled:
		AudioManager.play_sfx("hover_button")

func _on_RecipesButton_mouse_entered():
	if not recipes_button.disabled:
		AudioManager.play_sfx("hover_button")

func _on_RecipesButton_button_down():
	AudioManager.play_sfx("click")


func _on_PassTurnButton_button_down():
	AudioManager.play_sfx("click")


func _on_FavoriteButton_pressed(index: int):
	AudioManager.play_sfx("click")
	
	var button : FavoriteButton = favorites.get_child(index)
	var selected_reagents = has_reagents(button.reagent_array)
	if selected_reagents:
		if not autocomplete_grid(button.combination):
			AudioManager.play_sfx("error")
			#TODO: Blink restrain/restricted slots
	else:
		AudioManager.play_sfx("error")


func _on_FavoriteButton_mouse_entered(index: int):
	var button : FavoriteButton = favorites.get_child(index)
# warning-ignore:return_value_discarded
	var selected_reagents = has_reagents(button.reagent_array)
	if selected_reagents:
		for selected_reagent in selected_reagents:
			selected_reagent.highlight()


func _on_FavoriteButton_mouse_exited():
	unhighlight_reagents()


func _on_Grid_modified():
	if grid.is_empty():
		recipe_name_display.reset()
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

func _on_CombineButton_pressed():
	if grid.is_empty():
		AudioManager.play_sfx("error")
		return
	
	if player.get_status("deviation") and deviated_recipes.has(recipe_name_display.get_name()):
		AudioManager.play_sfx("error")
		return
	
	AudioManager.play_sfx("combine_button_click")
	
	grid.clear_hints()
	
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
	
	recipes_created += 1
	#Check curse
	var curse = player.get_status("curse")
	if curse:
		combine_button.set_curse(recipes_created, curse.amount)
