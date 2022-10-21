extends Node

func call_on_add(name : String, args : Dictionary):
	if has_method("on_add_" + name):
		call("on_add_" + name, args)

func call_on_battle_start(name : String, args : Dictionary):
	if has_method("on_battle_start_" + name):
		call("on_battle_start_" + name, args)

func call_on_battle_finish(name : String, args : Dictionary):
	if has_method("on_battle_finish_" + name):
		call("on_battle_finish_" + name, args)

func call_on_turn_start(name : String, args : Dictionary):
	if has_method("on_turn_start_" + name):
		call("on_turn_start_" + name, args)

func call_on_enemy_died(name : String, args : Dictionary):
	if has_method("on_enemy_died_" + name):
		call("on_enemy_died_" + name, args)

func call_on_discover_recipe(name : String, args : Dictionary):
	if has_method("on_discover_recipe_" + name):
		call("on_discover_recipe_" + name, args)

#On add methods

func on_add_coin_bag(args):
	AudioManager.play_sfx("get_coins")
	args.player.gold += 40

func on_add_poison_kit(args):
	AudioManager.play_sfx("status_poison")
	for _i in range(0,3):
		args.player.add_reagent("poison", false)

func on_add_buff_kit(args):
	AudioManager.play_sfx("buff")
	for _i in range(0,3):
		args.player.add_reagent("buff", false)

func on_add_debuff_kit(args):
	AudioManager.play_sfx("debuff")
	for _i in range(0,3):
		args.player.add_reagent("debuff", false)

func on_add_random_kit(args):
	AudioManager.play_sfx("get_loot")
	for _i in 4:
		args.player.add_reagent(ReagentManager.random_type(), false)
	var increase = ceil(float(args.player.max_hp)*0.2)
	args.player.set_max_hp(args.player.max_hp + increase)
	args.player.set_hp(args.player.hp + increase)

func on_add_trash_heal(args):
	AudioManager.play_sfx("debuff")
	for _i in range(0,4):
		args.player.add_reagent("trash_plus", false)

func on_add_max_hp(args):
	AudioManager.play_sfx("heal")
	args.player.set_max_hp(args.player.max_hp + 20)
	args.player.set_hp(args.player.hp + 20)

func on_add_midas(args):
	AudioManager.play_sfx("get_coins")
	args.player.gold *= 3

func on_add_money_bag(args):
	AudioManager.play_sfx("get_coins")
	args.player.gold += 40

func on_add_reveal_map(args):
	args.player.reveal_map()

func on_add_hand_veknor(args):
	var loss = ceil(args.player.max_hp*0.25)
	args.player.set_max_hp(args.player.max_hp - loss)
	args.player.set_hp(min(args.player.hp, args.player.max_hp))


#On battle start methods

func on_battle_start_carapa_buckler(args):
	args.player.gain_shield(10)

func on_battle_start_strength(args):
	args.player.add_status("perm_strength", 3, true)

func on_battle_start_strength_plus(args):
	args.player.add_status("perm_strength", 8, true)

func on_battle_start_temp_strength(args):
	args.player.add_status("temp_strength", 6, true)

func on_battle_start_temp_strength_plus(args):
	args.player.add_status("temp_strength", 12, true)

func on_battle_start_cursed_halberd(args):
	args.player.add_status("perm_strength", 5, true)
	args.player.take_damage(args.player, 8, "regular", false)

func on_battle_start_cursed_shield(args):
	args.player.take_damage(args.player, 8, "regular", false)

func on_battle_start_vulture_mask(args):
	if args.encounter.is_elite:
		args.player.add_status("perm_strength", 5, true)

#On battle finish methods

func on_battle_finish_mender_belt(args):
	args.player.heal(8)


func on_battle_finish_gold_ankh(args):
	args.player.increase_max_hp(10)
	args.player.heal(10)


#On battle turn start methods

func on_turn_start_cursed_shield(args):
	args.player.gain_shield(5)


#On enemy died methods

func on_enemy_died_bloodcursed_grimoire(args):
	args.player.heal(int(float(args.player.max_hp)/10.0))


#On discover a recipe

func on_discover_recipe_cursed_scholar_mask(args):
	AudioManager.play_sfx("heal")
	var amount = ceil(args.player.max_hp*.08)
	if args.source == "battle_win" or args.source == "battle":
		args.player.heal(amount)
	else:
		args.player.set_hp(min(args.player.hp + amount, args.player.max_hp))
