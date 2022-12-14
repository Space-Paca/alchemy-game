tool

extends Node2D

signal won
signal finished(is_boss, is_elite, is_final_boss)
signal combination_made(reagent_matrix)
signal current_reagents_updated(curr_reagents)
signal finished_enemies_init
signal combination_rewarded(combination)
signal rewarded_combinations_seen(combinations)
signal grid_modified(reagent_matrix)
signal recipe_book_toggle
signal hand_set
signal update_recipes_display
signal block_pause
signal player_died
signal finished_autocomplete

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
export(Array, Color) var backgrounds_elite_modulate
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
const EVENT_BACKGROUNDS = {
	"halloween": [
		preload("res://assets/images/background/halloween/forest.png"),
		preload("res://assets/images/background/halloween/cave.png"),
		preload("res://assets/images/background/halloween/dungeon.png")
	]
}
const BOSS_EVENT_BACKGROUNDS = {
	"halloween": [
		preload("res://assets/images/background/halloween/village.png"),
		preload("res://assets/images/background/halloween/fire.png")
	]
}

var floor_level
var difficulty := "normal"
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
var used_all_reagents_in_recipes = false
var recipe_book_visible = false
var is_event = false
var killing_minions = false
var exiled_reagents = []

func _ready():
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("battle_won", self, "_on_Debug_battle_won")
# warning-ignore:return_value_discarded
	Debug.connect("died", self, "_on_player_died")
# warning-ignore:return_value_discarded
	Debug.connect("damage_all", self, "_on_Debug_damage_all")
# warning-ignore:return_value_discarded
	Debug.connect("recipe_simulated", self, "_on_Debug_recipe_simulated")
	
	#Hoping to fix dim screen bug
	targeting_interface.end()


func _input(event):
	if not TutorialLayer.is_active() and not recipe_book_visible and\
	   not MessageLayer.is_active():
		if event.is_action_pressed("end_turn"):
				try_end_turn()
		elif event.is_action_pressed("combine"):
			if not combine_button.disabled and not is_grabbing_reagent():
				combine()
			else:
				AudioManager.play_sfx("error")
		elif not is_dragging_reagent:
			#Disabling shortcuts for now until we fix the related bugs
			for i in range(1, favorites.get_child_count() + 1):
				if event.is_action_pressed("favorite_"+str(i)):
					var fav = favorites.get_child(i - 1)
					if fav.is_enabled():
						fav.activate()
					else:
						AudioManager.play_sfx("error")



func get_save_data():
	var data = {
		"encounter": current_encounter.resource_name,
		"enemies": get_enemies_save_data(),
		"player": get_player_save_data(),
		"is_event": is_event,
		"encounter_phase": current_encounter.current_phase,
		"exiled_reagents": exiled_reagents,
	}

	
	return data


func get_player_save_data():
	var data = {
		"recipes_created": recipes_created,
		"deviated_recipes": deviated_recipes.duplicate(true),
		"used_all_reagents_in_recipes": used_all_reagents_in_recipes,
		"shield": player.shield,
		"status_list": player.status_list.duplicate(true),
		"bags": {
			"draw": draw_bag.get_data(),
			"discard": discard_bag.get_data(),
		},
		"hand": hand.get_data(),
		"grid": grid.get_data(),
	}
	
	return data

func get_enemies_save_data():
	var data = []
	for enemy in enemies_node.get_children():
		var enemy_data = {
			"name": enemy.enemy_type,
			"hp": enemy.hp,
			"shield": enemy.shield,
			"status_list": enemy.status_list.duplicate(true),
			"current_state": enemy.logic.get_current_state(),
			"actions": enemy.get_actions_data(),
		}
		data.append(enemy_data)
	
	return data


func load_state(data: Dictionary, _player: Player, favorite_combinations: Array, _floor_level: int, recipe_book : RecipeBook, _difficulty: String):
	emit_signal("block_pause", true)
	
	difficulty = _difficulty
	floor_level = _floor_level
	current_encounter = EncounterManager.load_resource(data.encounter)
	current_encounter.current_phase = data.encounter_phase
	
	is_event = data.is_event
	
	is_boss = current_encounter.is_boss and not is_event
	is_elite = current_encounter.is_elite or (current_encounter.is_boss and is_event)
	
	setup_bg()

	setup_nodes(_player)

	var reagents_to_be_draw = setup_player(_player, data.player)

	effect_manager.setup(_player)

	setup_favorites(favorite_combinations, recipe_book)

	setup_player_ui()

	setup_enemy(current_encounter, data.enemies)

	setup_audio()
	
	if data.has("exiled_reagents"):
		exiled_reagents = data.exiled_reagents
	else:
		exiled_reagents = []

	AudioManager.play_sfx("start_battle")
	
	#Wait sometime before showing book and starting battle
	yield(get_tree().create_timer(BG_ENTER_DUR + 1.0), "timeout")
	
	$BGTween.interpolate_property(book, "rect_position:x", BOOK_START_X, BOOK_TARGET_X, BOOK_ENTER_DUR, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$BGTween.start()

	yield($BGTween, "tween_completed")
	
	if Profile.get_tutorial("first_battle") and \
	   not Profile.get_tutorial("recipe_book"):
		Profile.set_tutorial("first_battle", false)
	
	if not Profile.get_tutorial("first_battle"):
		TutorialLayer.start("first_battle")
		yield(TutorialLayer, "tutorial_finished")
		Profile.set_tutorial("first_battle", true)
	
	load_player_turn(data.player, reagents_to_be_draw)
	
	emit_signal("block_pause", false)


func setup(_player: Player, encounter: Encounter, favorite_combinations: Array,
		_floor_level: int,  recipe_book : RecipeBook, _is_event := false, _difficulty := "normal"):
	emit_signal("block_pause", true)
	
	difficulty = _difficulty
	floor_level = _floor_level
	current_encounter = encounter
	is_event = _is_event
	
	is_boss = encounter.is_boss and not is_event
	is_elite = encounter.is_elite or (encounter.is_boss and is_event)

	setup_bg()

	setup_nodes(_player)

	setup_player(_player)

	effect_manager.setup(_player)

	setup_favorites(favorite_combinations, recipe_book)

	setup_player_ui()

	setup_enemy(encounter)

	setup_audio()

	AudioManager.play_sfx("start_battle")

	#Wait sometime before showing book and starting battle
	yield(get_tree().create_timer(BG_ENTER_DUR + 1.0), "timeout")

	$BGTween.interpolate_property(book, "rect_position:x", BOOK_START_X, BOOK_TARGET_X, BOOK_ENTER_DUR, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$BGTween.start()

	yield($BGTween, "tween_completed")

	while enemies_init():
		yield(self, "finished_enemies_init")
	
	if Profile.get_tutorial("first_battle") and \
	   not Profile.get_tutorial("recipe_book"):
		Profile.set_tutorial("first_battle", false)
	
	if not Profile.get_tutorial("first_battle"):
		TutorialLayer.start("first_battle")
		yield(TutorialLayer, "tutorial_finished")
		Profile.set_tutorial("first_battle", true)

	new_player_turn()
	
	emit_signal("block_pause", false)


func setup_bg():
	book.rect_position.x = BOOK_START_X

	if is_boss:
		if floor_level == 3:
			$FinalBossBG.show()
			if current_encounter.current_phase == 1:
				$FinalBossBG/AnimationPlayer.play("rotating")
			else:
				$FinalBossBG/AnimationPlayer.play("rotating_final_boss")
		if Debug.seasonal_event and floor_level < 3:
			$BG.texture = BOSS_EVENT_BACKGROUNDS[Debug.seasonal_event][floor_level-1]
		else:
			$BG.texture = boss_backgrounds[floor_level-1]
		$FG.texture = boss_foregrounds[floor_level-1]
	else:
		if Debug.seasonal_event:
			$BG.texture = EVENT_BACKGROUNDS[Debug.seasonal_event][floor_level-1]
		else:
			$BG.texture = backgrounds[floor_level-1]
		$BGEliteEffect.texture = $BG.texture
		$BGEliteEffect.modulate = backgrounds_elite_modulate[floor_level-1]
		$FG.texture = foregrounds[floor_level-1]
	
	$BGEliteEffect.visible = is_elite
	$BGTween.interpolate_property($BG, "rect_position:x", 0, -499, BG_ENTER_DUR, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$BGTween.interpolate_property($BGEliteEffect, "rect_position:x", 0, -499, BG_ENTER_DUR, Tween.TRANS_QUAD, Tween.EASE_OUT)
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


func setup_player(_player, player_data = null):
	player = _player

	#Setup player bag
	if not player_data:
		for bag_reagent in player.bag:
			var reagent = create_reagent(bag_reagent.type)
			if bag_reagent.upgraded:
				reagent.upgrade()
			draw_bag.add_reagent(reagent)
	else:
		for reagent_data in player_data.bags.draw:
			var reagent = create_reagent(reagent_data.type)
			reagent.load_data(reagent_data)
			draw_bag.add_reagent(reagent)
		for reagent_data in player_data.bags.discard:
			var reagent = create_reagent(reagent_data.type)
			reagent.load_data(reagent_data)
			discard_bag.add_reagent(reagent)

	#Setup player hand
	hand.set_hand(player.hand_size)
	var reagents_to_be_draw = []
	if player_data:
		for reagent_data in player_data.hand.reagents:
			var reagent = create_reagent(reagent_data.type)
			reagent.load_data(reagent_data)
			draw_bag.add_reagent(reagent)
			reagents_to_be_draw.append(reagent)
		if player_data.hand.frozen_slots > 0:
			hand.freeze_slots(player_data.hand.frozen_slots)
	
	
	#Setup player grid
	grid.set_grid(player.grid_size)
	if player_data:
		grid.load_data(player_data.grid)
	
	player.connect("artifacts_updated", player_ui, "update_artifacts")
	player.connect("died", self, "_on_player_died")
	player.connect("draw_reagent", self, "_on_player_draw_reagent")
	player.connect("reshuffle", self, "_on_player_reshuffle")
	player.connect("freeze_hand", self, "_on_player_freeze_hand")
	player.connect("restrict", self, "_on_player_restrict")

	player.set_hud(player_ui)
	
	if player_data:
		for status_name in player_data.status_list:
			var status = player_data.status_list[status_name]
			player.hard_set_status(status_name, status.amount, status.positive, status.extra_args)

	disable_player()
	
	if player_data:
		return reagents_to_be_draw


func setup_favorites(favorite_combinations: Array, recipe_book : RecipeBook):
	for combination in favorite_combinations:
		add_favorite(combination, recipe_book.is_mastered(combination))


func setup_player_ui():
	player_ui.set_life(player.max_hp, player.hp)

	player_ui.update_portrait(player.hp, player.max_hp)

	player_ui.update_artifacts(player)

func setup_enemy(encounter: Encounter, load_enemies_data = false):
	#Clean up dummy enemies
	for child in enemies_node.get_children():
		enemies_node.remove_child(child)
		child.queue_free()

	#Wait for BG to start placing enemies
	yield($BGTween, "tween_completed")
	if not load_enemies_data:
		for enemy in encounter.enemies:
			add_enemy(enemy)
			update_enemy_positions(encounter.enemies.size())
			yield(get_tree().create_timer(rand_range(.3, .7)), "timeout")
	else:
		for enemy_data in load_enemies_data:
			load_enemy(enemy_data)
			update_enemy_positions(load_enemies_data.size())
			yield(get_tree().create_timer(rand_range(.3, .7)), "timeout")


func enemies_init():
	var had_init = false
	for enemy in enemies_node.get_children():
		if enemy.data.battle_init and not enemy.already_inited:
			enemy.already_inited = true
			enemy.just_spawned = false
			had_init = true
			enemy.act()
			yield(enemy, "action_resolved")
			#Wait a bit before next enemy/start player turn
			yield(get_tree().create_timer(.3), "timeout")

	if had_init:
		emit_signal("finished_enemies_init")
	return had_init


func setup_audio():
	if is_boss:
		AudioManager.play_bgm("boss" + str(floor_level), 3)
	elif is_elite:
		AudioManager.play_bgm("elite" + str(floor_level), 3)
	else:
		AudioManager.play_bgm("battle" + str(floor_level), 3)
	AudioManager.play_ambience(floor_level)
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

	win_screen.set_loot(encounter.get_loot(is_event))


func create_reagent(type):
	var reagent = ReagentManager.create_object(type)
	reagent.rect_scale = Vector2(.8,.8)
	reagent.connect("started_dragging", self, "_on_reagent_drag")
	reagent.connect("stopped_dragging", self, "_on_reagent_stop_drag")
	reagent.connect("hovering", self, "_on_reagent_hover")
	reagent.connect("stopped_hovering", self, "_on_reagent_stop_hover")
	reagent.connect("quick_place", self, "_on_reagent_quick_place")
	reagent.connect("destroyed", self, "_on_reagent_destroyed")
	reagent.connect("exiled", self, "_on_reagent_exiled")
	reagent.connect("unrestrained_slot", self, "_on_reagent_unrestrained_slot")
	return reagent


func load_enemy(data):
	var enemy_node = EnemyManager.create_object(data.name, player, difficulty)
	enemies_node.add_child(enemy_node)

	enemy_node.position = $EnemyStartPosition.position
	enemy_node.update_life(data.hp, data.shield)
	for status_name in data.status_list:
		var status = data.status_list[status_name]
		enemy_node.hard_set_status(status_name, status.amount, status.positive, status.extra_args)

	#Idle sfx
	if enemy_node.data.use_idle_sfx:
		AudioManager.play_enemy_sfx(enemy_node.data.sfx, "idle")

	enemy_node.connect("action", self, "_on_enemy_acted")
	enemy_node.connect("died", self, "_on_enemy_died")
	enemy_node.connect("spawn_new_enemy", self, "spawn_new_enemy")
	enemy_node.connect("damage_player", self, "damage_player")
	enemy_node.connect("add_status_all_enemies", self, "add_status_all_enemies")
	effect_manager.add_enemy(enemy_node)

	randomize()
	yield(get_tree().create_timer(rand_range(.3, .4)), "timeout")
	AudioManager.play_enemy_sfx(enemy_node.data.sfx, "spawn")

	enemy_node.logic.set_state(data.current_state)
	enemy_node.load_actions(data.actions)

func add_enemy(enemy, initial_pos = false, just_spawned = false, is_minion = false):
	var enemy_node = EnemyManager.create_object(enemy, player, difficulty)
	enemies_node.add_child(enemy_node)

	if initial_pos:
		enemy_node.position = initial_pos
	else:
		enemy_node.position = $EnemyStartPosition.position

	if just_spawned:
		enemy_node.just_spawned = true
	
	#Check for unique bgm for this enemy
	if enemy_node.data.unique_bgm:
		AudioManager.play_bgm(enemy_node.data.unique_bgm, 3)
	
	#Idle sfx
	if enemy_node.data.use_idle_sfx:
		AudioManager.play_enemy_sfx(enemy_node.data.sfx, "idle")

	enemy_node.connect("action", self, "_on_enemy_acted")
	enemy_node.connect("died", self, "_on_enemy_died")
	enemy_node.connect("spawn_new_enemy", self, "spawn_new_enemy")
	enemy_node.connect("damage_player", self, "damage_player")
	enemy_node.connect("add_status_all_enemies", self, "add_status_all_enemies")
	effect_manager.add_enemy(enemy_node)
	
	if just_spawned:
		AudioManager.play_enemy_sfx(enemy_node.data.sfx, "spawn")
		AnimationManager.play("spawn", enemy_node.get_center_position(), .15)
	else:
		AudioManager.play_enemy_sfx(enemy_node.data.sfx, "spawn", rand_range(.2, .5))

	enemy_node.update_actions()
	
	if is_minion:
		yield(get_tree().create_timer(.1), "timeout")
		enemy_node.add_status("minion", 1, false)



func update_enemy_positions(override_count = -1):
	var enemy_count = enemies_node.get_child_count() if override_count == -1 else override_count
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

func load_player_turn(data, reagents_to_be_draw : Array):
	recipes_created = data.recipes_created
	deviated_recipes = data.deviated_recipes
	used_all_reagents_in_recipes = data.used_all_reagents_in_recipes
	
	player.hard_set_shield(data.shield)
	
	if not reagents_to_be_draw.empty():
		var reagents_array = reagents_to_be_draw.duplicate(true)
		for reagent in reagents_to_be_draw:
			draw_bag.draw_specific_reagent(reagent)
		draw_bag.start_drawing(reagents_to_be_draw)
		yield(draw_bag, "given_reagents_drawn")
		#Fix unstable reagents
		for reagent in reagents_array:
			if reagent.unstable:
				reagent.unstable = false
				reagent.toggle_unstable()
	
	enable_player()

	first_turn = false
	emit_signal("hand_set")


func new_player_turn():
	if ended:
		return

	recipes_created = 0
	deviated_recipes = []
	used_all_reagents_in_recipes = true
	player.new_turn()
	
	if first_turn:
		player.call_artifacts("battle_start", {"player": player, "encounter": current_encounter})
	
	if hand.available_slot_count() > 0:
		draw_bag.refill_hand()
		yield(draw_bag,"hand_refilled")
		emit_signal("update_recipes_display")

	if player.get_status("deterioration"):
		hand.exile_reagents(1)

	if player.get_status("burning"):
		hand.burn_reagents(player.get_status("burning").amount)

	if player.get_status("confusion"):
		var func_state = hand.randomize_reagents()
		if func_state and func_state.is_valid():
			yield(hand, "reagents_randomized")
			emit_signal("current_reagents_updated", hand.get_reagent_names())
	
	if player.get_status("restrain"):
		var func_state = grid.restrain(player.get_status("restrain").amount)
		if func_state and func_state.is_valid():
			yield(grid, "restrained")

	enable_player()

	if first_turn:
		first_turn = false
		emit_signal("hand_set")
	FileManager.save_run()


func new_enemy_turn():
	for enemy in enemies_node.get_children():
		if not enemy.just_spawned:
			var func_state = (enemy.new_turn() as GDScriptFunctionState)
			if func_state and func_state.is_valid():
				yield(enemy, "updated_visuals_complete")
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
	recipes_button.disabled = true
	player_disabled = true
	pass_turn_button.disabled = true
	combine_button.disable()
	set_favorites_disabled(true)

	for reagent in reagents.get_children():
		reagent.disable_dragging()


func enable_player():
	if ended or killing_minions:
		return
	draw_bag.enable()
	discard_bag.enable()
	recipes_button.disabled = false
	player_disabled = false
	if Profile.get_tutorial("recipe_book"):
		pass_turn_button.disabled = false
	#Check curse
	var curse = player.get_status("curse")
	if curse:
		combine_button.enable_curse()
		combine_button.set_curse(recipes_created, curse.amount)
	else:
		combine_button.disable_curse()

	if Profile.get_tutorial("recipe_book") and (not curse or curse.amount > recipes_created):
		combine_button.enable()

	set_favorites_disabled(false)

	for reagent in reagents.get_children():
		reagent.enable_dragging()


func recipe_book_toggled(visible: bool):
	recipe_book_visible = visible
	if visible:
		recipes_button.hide()
		recipes_button.reset_offset()
		pass_turn_button.hide()
		pass_turn_button.reset_offset()
		player_ui.disable_tooltips()
		TooltipLayer.clean_tooltips()
		for reagent in reagents.get_children():
			reagent.disable_tooltips()
			reagent.disable_dragging()
		for favorite in favorites.get_children():
			favorite.disable_tooltips()
		draw_bag.disable()
		discard_bag.disable()
		grid.hide_effects()
		hand.hide_effects()

		if not Profile.get_tutorial("recipe_book"):
			TutorialLayer.start("recipe_book")
			yield(TutorialLayer, "tutorial_finished")
			Profile.set_tutorial("recipe_book", true)
			pass_turn_button.disabled = false
			combine_button.enable()
	else:
		player_ui.enable_tooltips()
		recipes_button.show()
		pass_turn_button.show()
		for reagent in reagents.get_children():
			reagent.enable_tooltips()
			reagent.enable_dragging()
		for favorite in favorites.get_children():
			favorite.enable_tooltips()
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
		destroy_reagents: Array = [], exile_reagents: Array = [], boost_effects: Dictionary = {}):
	if effects[0] == "combination_failure":
		grid.misfire_animation()
		used_all_reagents_in_recipes = false
		effect_manager.combination_failure(effect_args, grid)
		yield(effect_manager, "failure_resolved")
		grid.end_misfire_animation()
	else:
		# Destroy reagents if needed
		for reagent in destroy_reagents:
			if grid.destroy_reagent(reagent):
				yield(grid, "reagent_destroyed")
		# Exile reagents if needed
		for reagent in exile_reagents:
			if grid.exile_reagent(reagent):
				yield(grid, "reagent_exiled")
	
		# Discard reagents
		grid.clean()
		
		# Show grid animation
		grid.recipe_made_animation()
		
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
	if Profile.get_option("auto_end_turn") and hand.is_empty():
		yield(get_tree().create_timer(.2), "timeout")
		try_end_turn()


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
		enemy.disable_tooltips()
	for reagent in reagents.get_children():
		reagent.disable_tooltips()


func enable_elements():
	for enemy in enemies_node.get_children():
		enemy.enable()
	for reagent in reagents.get_children():
		reagent.enable_tooltips()


func is_final_boss():
	return is_boss and\
			((not Debug.is_demo and floor_level >= Debug.MAX_FLOOR) or\
			(Debug.is_demo and floor_level >= Debug.MAX_FLOOR - 1))


func win():
	if ended:
		return
	
	ended = true
	disable_elements()
	emit_signal("block_pause", true)
	
	if recipe_book_visible:
		emit_signal("recipe_book_toggle")
	
	if is_boss:
		AudioManager.play_sfx("win_boss_battle")
	else:
		AudioManager.play_sfx("win_normal_battle")
	AudioManager.stop_bgm()
	AudioManager.stop_all_enemy_idle_sfx()

	if is_final_boss():
		_on_win_screen_continue_pressed(true)
	else:
		setup_win_screen(current_encounter)

		TooltipLayer.clean_tooltips()
		disable_player()
		player.clear_status()

		player.call_artifacts("battle_finish", {"player": player, "encounter": current_encounter})

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
	if enemies_node.get_child_count() < enemy_idx + 1:
		return
	var enemy = enemies_node.get_child(enemy_idx)
	var target_pos = get_node("EnemiesPositions/Pos"+str(pos_idx))
	enemy.set_pos(target_pos.position)


func is_grabbing_reagent():
	for reagent in reagents.get_children():
		if reagent.is_drag:
			return true
	return false


func autocomplete_grid(combination: Combination):
	yield(get_tree(), "idle_frame")
	
	#Return already placed reagents to hand
	var to_return = []
	for slot in grid.slots.get_children():
		if slot.current_reagent:
			to_return.append(slot.current_reagent)
	for i in to_return.size():
		var reagent = to_return[i]
		hand.place_reagent(reagent)
		if i == to_return.size() -1:
			yield(hand, "reagent_placed")
	
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
								break
					if not valid_hint:
						break
				#Found valid offset
				if valid_hint:
					var count = selected_reagents.size()
					for i in range(combination.grid_size):
						for j in range(combination.grid_size):
							if combination.matrix[i][j]:
								var slot = grid.slots.get_child((i+off_i) * grid.grid_size + (j+off_j))
								for idx in selected_reagents.size():
									if selected_reagents[idx] and selected_reagents[idx] == combination.matrix[i][j]:
										var reagent = reagents.get_child(idx)
										if not reagent.is_burned():
											selected_reagents[idx] = false
											count -= 1
											if not reagent.slot:
												push_error("reagent isn't in slot")
											var func_state = slot.set_reagent(reagent)
											if count <= 0:
												if func_state and func_state.is_valid():
													yield(slot, "reagent_set")
												else:
													yield(get_tree(), "idle_frame")
											break
					#Could autocomplete
					emit_signal("finished_autocomplete")
					return
	#Couldn't autocomplete
	AudioManager.play_sfx("error")
	grid.highlight_blocked_slots()
	emit_signal("finished_autocomplete")
	return


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


func add_favorite(combination: Combination, is_mastered : bool):
	for button in favorites.get_children():
		if not button.combination:
			button.set_combination(combination, is_mastered)
			button.show_button()
			break


func remove_favorite(combination: Combination):
	for button in favorites.get_children():
		if button.combination == combination:
			button.set_combination(null)
			button.hide_button()


func update_favorite_mastery(combination):
	for button in favorites.get_children():
		if button.combination == combination:
			button.set_mastery(true)


func display_name_for_combination(combination, mastered):
	recipe_name_display.display_name_for_combination(combination, true, mastered)


func spawn_new_enemy(origin: Enemy, new_enemy: String, is_minion:= false):
	if enemies_node.get_child_count()  < MAX_ENEMIES:
		add_enemy(new_enemy, origin.get_center_position(), true, is_minion)
		update_enemy_positions()


func damage_player(source, value, type, use_modifiers:= true):
	var mod = source.get_damage_modifiers() if use_modifiers else 0
	var amount = max(0, value + mod)
	player.take_damage(source, amount, type)


func add_status_all_enemies(status, amount, positive, extra_args = {}):
	for enemy in enemies_node.get_children():
		enemy.add_status(status, amount, positive, extra_args)


func try_end_turn():
	if pass_turn_button.disabled:
		AudioManager.play_sfx("error")
	else:
		end_turn()


func end_turn():
	if player_disabled:
		return

	if not grid.is_empty():
		grid.return_to_hand()
		return

	player.update_status("end_turn")

	disable_player()

	#Check for artifacts effects
	if player.has_artifact("heal_leftover"):
		for reagent in reagents.get_children():
			effect_manager.heal(2)
			yield(get_tree().create_timer(.3), "timeout")
	if reagents.get_children().size() <= 0 and used_all_reagents_in_recipes:
		if player.has_artifact("damage_optimize"):
			effect_manager.damage_all(30, "regular")
			yield(effect_manager, "effect_resolved")
		if player.has_artifact("heal_optimize"):
			effect_manager.heal(30)
			yield(effect_manager, "effect_resolved")
		if player.has_artifact("strength_optimize"):
			effect_manager.add_status("self", "perm_strength", 10, true)
			yield(effect_manager, "effect_resolved")

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

func combine():
	if player_disabled:
		return

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
	var sfx_player = AudioManager.play_sfx("combine")
	var dur
	if Profile.get_option("turbo_mode"):
		dur = .2
	else:
		dur = min(reagent_list.size()*.3, AudioManager.get_sfx_duration("combine"))
	for reagent in reagent_list:
		reagent.combine_animation(grid.get_center(), dur, true)
	grid.combination_animation(dur*1.3)

	yield(reagent_list.front(), "finished_combine_animation")
	sfx_player.stop()
	
	emit_signal("combination_made", reagent_matrix, reagent_list)
	emit_signal("current_reagents_updated", hand.get_reagent_names())

	recipes_created += 1
	#Check curse
	var curse = player.get_status("curse")
	if curse:
		combine_button.set_curse(recipes_created, curse.amount)


func _on_reagent_drag(reagent):
	reagents.move_child(reagent, reagents.get_child_count()-1)
	is_dragging_reagent = true
	if reagent.is_burned():
		reagent.unburn()
		AudioManager.play_sfx("fire_reagent")
		player.take_damage(player, 6, "regular", false)


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
			player.take_damage(player, 9, "regular", false)
		if reagent.slot.type == "grid":
			if hand.available_slot_count() > 0:
				AudioManager.play_sfx("quick_place_hand")
				hand.place_reagent(reagent)
		elif reagent.slot.type == "hand":
			grid.quick_place(reagent)


func _on_reagent_destroyed(reagent):
	player.remove_reagent(reagent.type, reagent.upgraded)


func _on_reagent_exiled(reagent):
	exiled_reagents.append(reagent)


func _on_reagent_unrestrained_slot(reagent, slot):
	slot.unrestrain()
	reagent.slot.remove_reagent()
	discard_bag.discard(reagent)

func _on_enemy_acted(enemy, actions):
	for action in actions:
		if ended:
			return
		var name = action[0]
		var args = action[1]
		if name == "damage":
			var amount = max(0, args.value + enemy.get_damage_modifiers())
			for i in range(0, args.amount):
				enemy.play_animation(args.animation)
				AudioManager.play_enemy_sfx(enemy.data.sfx, "attack")
				var func_state = player.take_damage(enemy, amount, args.type)
				if i == args.amount - 1:
					enemy.remove_intent()
				#Wait before going to next action/enemy
				if args.amount > 1 and i != args.amount - 1:
					var dur = .3 if Profile.get_option("turbo_mode") else .8
					yield(get_tree().create_timer(dur/args.amount), "timeout")
				elif func_state and func_state.is_valid():
					yield(player, "resolved")
				else:
					var dur = .1 if Profile.get_option("turbo_mode") else .5
					yield(get_tree().create_timer(dur), "timeout")
			enemy.remove_status("temp_strength")
		if name == "drain":
			var amount = max(0, args.value + enemy.get_damage_modifiers())
			for i in range(0, args.amount):
				enemy.play_animation(args.animation)
				AudioManager.play_enemy_sfx(enemy.data.sfx, "attack")
				var func_state = player.drain(enemy, amount)
				if i == args.amount - 1:
					enemy.remove_intent()
				#Wait before going to next action/enemy
				if func_state and func_state.is_valid():
					yield(player, "resolved")
				else:
					var dur = .1 if Profile.get_option("turbo_mode") else .5
					yield(get_tree().create_timer(dur), "timeout")
			enemy.remove_status("temp_strength")
		if name == "self_destruct":
			#enemy.play_animation("self_destruct")
			enemy.take_damage(enemy, enemy.hp, "piercing")
			yield(get_tree().create_timer(.1), "timeout")
			var amount = max(0, args.value + enemy.get_damage_modifiers())
			var func_state = player.take_damage(enemy, amount, "piercing")
			#Wait before going to next action/enemy
			if func_state and func_state.is_valid():
				yield(player, "resolved")
			else:
				var dur = .1 if Profile.get_option("turbo_mode") else .5
				yield(get_tree().create_timer(dur), "timeout")

			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			var dur = .1 if Profile.get_option("turbo_mode") else .5
			yield(get_tree().create_timer(dur), "timeout")
		elif name == "shield":
			enemy.play_animation(args.animation)
			enemy.gain_shield(args.value)
			enemy.remove_intent()
			#Wait before going to next action/enemy
			yield(enemy, "resolved")
		elif name == "status":
			enemy.play_animation(args.animation)
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
			var dur = .1 if Profile.get_option("turbo_mode") else .5
			yield(get_tree().create_timer(dur), "timeout")
		elif name == "heal":
			enemy.play_animation(args.animation)
			var value = args.value
			if args.target == "self":
				var func_state = enemy.heal(value)
				if func_state and func_state.is_valid():
					yield(enemy, "resolved")
				else:
					var dur = .1 if Profile.get_option("turbo_mode") else .5
					yield(get_tree().create_timer(dur), "timeout")
			elif args.target == "all_enemies":
				for e in enemies_node.get_children():
					e.heal(value)
					var dur = .1 if Profile.get_option("turbo_mode") else .5
					yield(get_tree().create_timer(dur), "timeout")
			else:
				push_error("Not a valid target for heal effect:" + str(args.target))
				assert(false)
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			var dur = .1 if Profile.get_option("turbo_mode") else .5
			yield(get_tree().create_timer(dur), "timeout")
		elif name == "spawn":
			enemy.play_animation(args.animation)
			var minion = args.has("minion")
			spawn_new_enemy(enemy, args.enemy, minion)
			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			var dur = .2 if Profile.get_option("turbo_mode") else .6
			yield(get_tree().create_timer(dur), "timeout")
		elif name == "add_reagent":
			enemy.play_animation(args.animation)
			for _i in range(0, args.value):
				AudioManager.play_sfx("create_trash_reagent")
				var reagent = create_reagent(args.type)
				reagents.add_child(reagent)
				randomize()
				var offset = Vector2(rand_range(-10, 10), rand_range(-10, 10))
				reagent.rect_position = enemy.position + offset
				reagent.super_grow()
				var dur = .1 if Profile.get_option("turbo_mode") else .2
				yield(get_tree().create_timer(dur), "timeout")
				discard_bag.discard(reagent)
				dur = .1 if Profile.get_option("turbo_mode") else .3
				yield(get_tree().create_timer(dur), "timeout")
			enemy.remove_intent()
			emit_signal("update_recipes_display")
			#Wait a bit before going to next action/enemy
			var dur = .1 if Profile.get_option("turbo_mode") else .5
			yield(get_tree().create_timer(dur), "timeout")
		elif name == "idle":
			if args.has("sfx"):
				AudioManager.play_sfx(args.sfx)

			enemy.remove_intent()
			#Wait a bit before going to next action/enemy
			var dur = .1 if Profile.get_option("turbo_mode") else .5
			yield(get_tree().create_timer(dur), "timeout")

	enemy.action_resolved()


func _on_enemy_died(enemy):
	player.increase_floor_stat("monsters_defeated")
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
		AudioManager.stop_bgm(.5, false)
		var dur = .5 if Profile.get_option("turbo_mode") else 1.5
		yield(get_tree().create_timer(dur), "timeout")
		current_encounter.current_phase += 1
		$FinalBossBG/AnimationPlayer.play("rotating_final_boss")
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
	
	player.call_artifacts("enemy_died", {"player": player, "encounter": current_encounter})
	
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
		killing_minions = true
		for enemy in enemies_node.get_children():
			if enemy.get_status("minion"):
				enemy.die()


func _on_player_died(_player):
	emit_signal("block_pause", true)
	emit_signal("player_died")
	AudioManager.play_sfx("game_over")
	TooltipLayer.clean_tooltips()
	ended = true
	disable_player()
	disable_elements()
	Profile.set_stat("gameover", Profile.get_stat("gameover") + 1)
	FileManager.delete_run_file()
	var gameover = GAMEOVER_SCENE.instance()
	gameover.set_player(player)
	add_child(gameover)
	AudioManager.play_bgm("gameover", false, true)
	AudioManager.stop_aux_bgm("heart-beat")
	AudioManager.stop_all_enemy_idle_sfx()


func _on_player_reshuffle():
	draw_bag.reshuffle()
	yield(draw_bag, "reshuffled")
	player.reshuffle_resolve()


func _on_player_draw_reagent(amount, should_reshuffle):
	draw_bag.draw_reagents(amount, should_reshuffle)
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
	end_turn()


func _on_RecipesButton_pressed():
	emit_signal("recipe_book_toggle")


func _on_win_screen_continue_pressed(final_boss := false):
	emit_signal("block_pause", false)
	emit_signal("finished", is_boss, is_elite, final_boss)


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
		AudioManager.play_sfx("hover_tabs")

func _on_RecipesButton_mouse_entered():
	if not recipes_button.disabled:
		AudioManager.play_sfx("hover_tabs")

func _on_RecipesButton_button_down():
	AudioManager.play_sfx("click")


func _on_PassTurnButton_button_down():
	AudioManager.play_sfx("click")


func _on_FavoriteButton_pressed(index: int):
	if is_dragging_reagent:
		AudioManager.play_sfx("error")
		return
	AudioManager.play_sfx("click")
	disable_player()
	var button : FavoriteButton = favorites.get_child(index)
	var selected_reagents = has_reagents(button.reagent_array)
	if selected_reagents:
		autocomplete_grid(button.combination)
		yield(self, "finished_autocomplete")
	else:
		AudioManager.play_sfx("error")
		for reagent in reagents.get_children():
			reagent.error_effect()
	enable_player()


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


func _on_Debug_damage_all():
	for enemy in enemies_node.get_children():
		enemy.take_damage(player, 9999, "piercing", false)
	disable_player()


func _on_Debug_battle_won():
	win()


func _on_CombineButton_pressed():
	combine()


func _on_Debug_recipe_simulated(recipe: Recipe):
	disable_player()
	apply_effects(recipe.effects, recipe.effect_args, [], [], {"all": 0,
			"damage": 0, "shield": 0, "status": 0, "heal": 0})
