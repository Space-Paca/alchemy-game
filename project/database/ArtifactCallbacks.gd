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

func on_add_trash_heal(args):
	AudioManager.play_sfx("debuff")
	for _i in range(0,4):
		args.player.add_reagent("trash", false)

func on_add_max_hp(args):
	AudioManager.play_sfx("heal")
	args.player.max_hp += 20
	args.player.hp += 20

func on_add_midas(args):
	AudioManager.play_sfx("get_coins")
	args.player.gold *= 3

func on_add_money_bag(args):
	AudioManager.play_sfx("get_coins")
	args.player.gold += 30

func on_add_reveal_map(args):
	args.player.reveal_map()

#On battle start methods
func on_battle_start_carapa_buckler(args):
	args.player.gain_shield(10)

func on_battle_start_strength(args):
	args.player.add_status("perm_strength", 3, true)

func on_battle_start_strength_plus(args):
	args.player.add_status("perm_strength", 8, true)

func on_battle_start_temp_strength(args):
	args.player.add_status("temp_strength", 10, true)

func on_battle_start_temp_strength_plus(args):
	args.player.add_status("temp_strength", 20, true)

#On battle finish methods
func on_battle_finish_mender_belt(args):
	args.player.heal(8)


