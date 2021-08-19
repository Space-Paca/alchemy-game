extends Node

const IMAGES = {
	"regular_attack": preload("res://assets/images/intents/attack_normal.png"),
	"piercing_attack": preload("res://assets/images/intents/attack_piercing.png"),
	"crushing_attack": preload("res://assets/images/intents/attack_crushing.png"),
	"venom_attack": preload("res://assets/images/intents/attack_venom.png"),
	"drain": preload("res://assets/images/intents/attack_drain.png"),
	"self_destruct": preload("res://assets/images/intents/self_destruct.png"),
	"shield": preload("res://assets/images/intents/blocking.png"),
	"buff": preload("res://assets/images/intents/buffing.png"),
	"heal": preload("res://assets/images/intents/buffing.png"),
	"debuff": preload("res://assets/images/intents/debuffing.png"),
	"spawn": preload("res://assets/images/intents/summoning.png"),
	"random": preload("res://assets/images/intents/random.png"),
}


#Creates an intent based on an action
func create_intent_data(action):
	var intent = {}
	intent.action = action
	var name = action[0]
	var args = action[1]
	if name == "damage":
		if args.type == "regular":
			intent.image = IMAGES.regular_attack
		elif args.type == "piercing":
			intent.image = IMAGES.piercing_attack
		elif args.type == "crushing":
			intent.image = IMAGES.crushing_attack
		elif args.type == "venom":
			intent.image = IMAGES.venom_attack
		intent.value = args.value
		if args.amount > 1:
			intent.multiplier = args.amount
	elif name == "drain":
		intent.image = IMAGES.drain
		intent.value = args.value
		if args.amount > 1:
			intent.multiplier = args.amount
	elif name == "self_destruct":
		intent.image = IMAGES.self_destruct
		intent.value = args.value
	elif name == "shield":
		intent.image = IMAGES.shield
		intent.value = args.value
	elif name == "heal":
		intent.image = IMAGES.heal
		intent.value = args.value
	elif name == "status":
		if args.positive:
			intent.image = IMAGES.buff
		else:
			intent.image = IMAGES.debuff
		if args.has("reduce") and args.reduce:
			intent.value = -args.value
		else:
			intent.value = args.value
	elif name == "spawn":
		intent.image = IMAGES.spawn
	elif name == "add_reagent":
		intent.image = IMAGES.random
	elif name == "idle":
		intent.image = IMAGES.random
	else:
		push_error("Not a known action:" + str(name))
		assert(false)
	
	return intent

func get_intent_tooltip(action, enemy):
	var tooltip = {}
	var name = action[0]
	var args = action[1]
	if name == "damage":
		var value = args.value
		value += enemy.get_damage_modifiers()
		value = int(ceil(2*value/3.0)) if enemy.get_status("weakness") else value
		tooltip.title = tr("INTENT_ATTACKING_TITLE")
		if args.amount > 1:
			tooltip.text = tr("INTENT_ATTACKING_PLURAL_DESC") % [value, tr((args.type + "_DAMAGE").to_upper()), args.amount]
		else:
			tooltip.text = tr("INTENT_ATTACKING_DESC") % [value, tr((args.type + "_DAMAGE").to_upper())]
		
		if args.type == "regular":
			tooltip.title_image = IMAGES.regular_attack
		elif args.type == "piercing":
			tooltip.title_image = IMAGES.piercing_attack
		elif args.type == "crushing":
			tooltip.title_image = IMAGES.crushing_attack
		elif args.type == "venom":
			tooltip.title_image = IMAGES.venom_attack
	elif name == "drain":
		var value = args.value
		value += enemy.get_damage_modifiers()
		value = int(ceil(2*value/3.0)) if enemy.get_status("weakness") else value
		tooltip.title = tr("INTENT_DRAINING_TITLE")
		if args.amount > 1:
			tooltip.text = tr("INTENT_DRAINING_PLURAL_DESC") % [value, args.amount]
		else:
			tooltip.text = tr("INTENT_DRAINING_DESC") % [value]
		tooltip.title_image = IMAGES.drain
	elif name == "shield":
		tooltip.title = tr("INTENT_DEFENDING_TITLE")
		tooltip.text = tr("INTENT_DEFENDING_DESC") % [args.value]
		tooltip.title_image = IMAGES.shield
	elif name == "heal":
		tooltip.title_image = IMAGES.heal
		if args.target == "self":
			tooltip.title = tr("INTENT_HEALING_TITLE")
			tooltip.text = tr("INTENT_HEALING_DESC") % [args.value]
		elif args.target == "all_enemies":
			tooltip.title = tr("INTENT_HEALING_ALL_TITLE")
			tooltip.text = tr("INTENT_HEALING_ALL_DESC") % [args.value]
	elif name == "self_destruct":
		tooltip.title = tr("INTENT_SELF_DESTRUCT_TITLE")
		tooltip.text = tr("INTENT_SELF_DESTRUCT_DESC") % [args.value]
		tooltip.title_image = IMAGES.self_destruct
	elif name == "status":
		var status_data = StatusDB.get_from_name(args.status)
		tooltip.title = status_data.intent_title
		
		if args.positive:
			tooltip.title_image = IMAGES.buff
		else:
			tooltip.title_image = IMAGES.debuff
			
		var target
		if args.has("reduce") and args.reduce:
			target = "REMOVE"
		elif args.target == "self":
			target = "SELF"
		else:
			target = "ENEMY"
		if args.value > 1:
			tooltip.text = "INTENT_STATUS_"+target+"_DESC" % [tr(status_data["title_name"])]
		else:
			tooltip.text = "INTENT_STATUS_"+target+"_PLURAL_DESC" % [args.value, tr(status_data["title_name"])]
	elif name == "spawn":
		tooltip.title = tr("INTENT_SPAWNING_TITLE")
		tooltip.text = tr("INTENT_SPAWNING_DESC")
		tooltip.title_image = IMAGES.spawn
	elif name == "add_reagent":
		tooltip.title = tr("INTENT_ADDING_REAGENT_TITLE")
		tooltip.text = tr("INTENT_ADDING_REAGENT_DESC")
		tooltip.title_image = IMAGES.random
	elif name == "idle":
		tooltip.title = tr("INTENT_IDLE_TITLE")
		tooltip.text = tr("INTENT_IDLE_DESC")
		tooltip.title_image = IMAGES.random
	else:
		push_error("Not a known action:" + str(name))
		assert(false)
	
	return tooltip
