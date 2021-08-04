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
		tooltip.title = "Attacking"
		var amount_text
		if args.amount > 1:
			amount_text = " " + str(args.amount) + " times"
		else:
			amount_text = ""
		tooltip.text = "This enemy is going to deal " + str(value) + " " + \
					   args.type + " damage" + amount_text +  " next turn"
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
		tooltip.title = "Draining"
		var amount_text
		if args.amount > 1:
			amount_text = " " + str(args.amount) + " times"
		else:
			amount_text = ""
		tooltip.text = "This enemy is going to drain " + str(value) + \
					   amount_text +  " next turn"
		tooltip.title_image = IMAGES.drain
	elif name == "shield":
		tooltip.title = "Defending"
		tooltip.text = "This enemy is getting " + str(args.value) + " shield next turn"
		tooltip.title_image = IMAGES.shield
	elif name == "heal":
		tooltip.title_image = IMAGES.heal
		if args.target == "self":
			tooltip.title = "Healing"
			tooltip.text = "This enemy is healing " + str(args.value) + " next turn"
		elif args.target == "all_enemies":
			tooltip.title = "Healing all Enemies"
			tooltip.text = "This enemy is healing all enemies by " + str(args.value) + " next turn"
	elif name == "self_destruct":
		tooltip.title = "Self Destructing"
		tooltip.text = "This enemy will destroy itself next turn, dealing " + str(args.value) + " piercing damage to the player as result"
		tooltip.title_image = IMAGES.self_destruct
	elif name == "status":
		var verb
		if args.positive:
			tooltip.title_image = IMAGES.buff
		else:
			tooltip.title_image = IMAGES.debuff
			
		if args.target == "self":
			verb = "getting"
		else:
			verb = "applying"
		
		if args.has("reduce") and args.reduce:
			verb = "removing"

		tooltip.text = "This character is " + verb + " "
		
		if args.value > 1:
			tooltip.text += str(args.value) + " "
		
		var status_data = StatusDB.get_from_name(args.status)
		tooltip.title = status_data.intent_title
		tooltip.text += tr(status_data["title_name"])
		
		tooltip.text += " next turn"
	elif name == "spawn":
		tooltip.title = "Spawning"
		tooltip.text = "This enemy is spawning another enemy next turn"
		tooltip.title_image = IMAGES.spawn
	elif name == "add_reagent":
		tooltip.title = "Adding reagent"
		tooltip.text = "This enemy is going to add a reagent to your bag next turn"
		tooltip.title_image = IMAGES.random
	elif name == "idle":
		tooltip.title = "Preparing"
		tooltip.text = "This enemy is preparing something..."
		tooltip.title_image = IMAGES.random
	else:
		push_error("Not a known action:" + str(name))
		assert(false)
	
	return tooltip
