class_name StatusDB

const STATUSES = {
   "arcane_aegis": {
	"title_name": "Arcane Aegis",
	"description": "Whenever this characters is attacked, if it wasn't shielded, gains shield",
	"image": preload("res://assets/images/status/arcane_aegis.png"),
	"intent_title": "Casting Arcane Aegis",
	"in-text_name": "arcane aegis"},
   "avenge": {
	"title_name": "Avenge",
	"description": "When an ally dies, this character gains permanent strength",
	"image": preload("res://assets/images/status/avenge.png"),
	"intent_title": "Avenging",
	"in-text_name": "avenge"},
   "burning": {
	"title_name": "Burning",
	"description": "At start of turn, will randomly burn player's reagents until end of turn",
	"image": preload("res://assets/images/status/burning.png"),
	"intent_title": "Immolate",
	"in-text_name": "burning"},
   "concentration": {
	"title_name": "Concentration",
	"description": "If this character takes enough damage, it will lose focus and stop attacking",
	"image": preload("res://assets/images/status/concentration.png"),
	"intent_title": "Concentrating",
	"in-text_name": "concentration"},
   "confusion": {
	"title_name": "Confusion",
	"description": "Transforms reagents randomly at the start of every turn",
	"image": preload("res://assets/images/status/confusion.png"),
	"intent_title": "Dazzling",
	"in-text_name": "confusion"},
   "curse": {
	"title_name": "Curse",
	"description": "Limits the number of recipes you can try to create each turn",
	"image": preload("res://assets/images/status/curse.png"),
	"intent_title": "Cursing",
	"in-text_name": "curse"},
   "deep_wound": {
	"title_name": "Deep Wound",
	"description": "This character can't heal",
	"image": preload("res://assets/images/status/deep_wound.png"),
	"intent_title": "Wounding",
	"in-text_name": "deep wound"},
   "deviation": {
	"title_name": "Deviation",
	"description": "This character can't repeat recipes on the same turn",
	"image": preload("res://assets/images/status/deviation.png"),
	"intent_title": "Deviating",
	"in-text_name": "deviation"},
   "divine_protection": {
	"title_name": "Divine Protection",
	"description": "Every turn, this character becomes invincible after taking enough damage",
	"image": preload("res://assets/images/status/divine_protection.png"),
	"intent_title": "Favor from the Gods",
	"in-text_name": "Divine protection"},
   "dodge": {
	"title_name": "Dodge",
	"description": "This character will avoid the next attack. Last until end of turn.",
	"image": preload("res://assets/images/status/dodge.png"),
	"intent_title": "Dodging",
	"in-text_name": "dodge"},
   "enrage": {
	"title_name": "Enrage",
	"description": "Whenever this character takes damage, it gets 1 permanent strength per stack",
	"image": preload("res://assets/images/status/enrage.png"),
	"intent_title": "Raging",
	"in-text_name": "enrage"},
   "evasion": {
	"title_name": "Evasion",
	"description": "This character has 50% chance of avoiding the next attack. Last until it triggers or end of turn",
	"image": preload("res://assets/images/status/evasion.png"),
	"intent_title": "Evading",
	"in-text_name": "evasion"},
   "freeze": {
	"title_name": "Freezing",
	"description": "At start of turn, will freezes player's hand slots until end of turn",
	"image": preload("res://assets/images/status/freeze.png"),
	"intent_title": "Freezing",
	"in-text_name": "freeze"},
   "hex": {
	"title_name": "Hex",
	"description": "This character gains permanent strength each time you misuse a reagent",
	"image": preload("res://assets/images/status/hex.png"),
	"intent_title": "Hexing",
	"in-text_name": "hex"},
   "impending_doom": {
	"title_name": "Impending Doom",
	"description": "When this counter reaches 0, this character will receive 999 permanent strength",
	"image": preload("res://assets/images/status/impending_doom.png"),
	"intent_title": "Dooming",
	"in-text_name": "impending doom"},
   "martyr": {
	"title_name": "Martyr",
	"description": "When this character dies, it apply 1 permanent strength per stack to each other enemy",
	"image": preload("res://assets/images/status/martyr.png"),
	"intent_title": "Martyrdom",
	"in-text_name": "martyr"},
   "minion": {
	"title_name": "Minion",
	"description": "This enemy will disappear if his summoner dies",
	"image": preload("res://assets/images/status/minion.png"),
	"intent_title": "Minion",
	"in-text_name": "minion"},
   "perm_strength": {
	"title_name": "Permanent Strength",
	"description": "Permanently increases this character attack damage in recipes",
	"image": preload("res://assets/images/status/perm_strength.png"),
	"intent_title": "Powering up",
	"in-text_name": "permanent strength"},
   "poison": {
	"title_name": "Poison",
	"description": "This character is dealt 1 poison damage per stack at the end of its turn. Decreases every turn",
	"image": preload("res://assets/images/status/poison.png"),
	"intent_title": "Poisoning",
	"in-text_name": "poison"},
   "poison_immunity": {
	"title_name": "Poison Immunity",
	"description": "This character can't receive poison",
	"image": preload("res://assets/images/status/poison_immunity.png"),
	"intent_title": "Immunizing",
	"in-text_name": "poison immunity"},
   "restrain": {
	"title_name": "Restrained",
	"description": "Locks grid slots randomly until end of turn. You can spend reagents to unlock them",
	"image": preload("res://assets/images/status/restrain.png"),
	"intent_title": "Restraining",
	"in-text_name": "restrain"},
   "restrict_major": {
	"title_name": "Major Restriction",
	"description": "Blocks a number of grid slots until end of turn",
	"image": preload("res://assets/images/status/restrict_major.png"),
	"intent_title": "Chaining",
	"in-text_name": "major restriction"},
   "restrict_minor": {
	"title_name": "Minor Restriction",
	"description": "Blocks a number of grid slots until end of turn",
	"image": preload("res://assets/images/status/restrict_minor.png"),
	"intent_title": "Binding",
	"in-text_name": "minor restriction"},
   "retaliate": {
	"title_name": "Retaliate",
	"description": "This character returns 1 regular damage per stack each time it is attacked. Lasts until end of turn",
	"image": preload("res://assets/images/status/retaliate.png"),
	"intent_title": "Retaliating",
	"in-text_name": "retaliate"},
   "revenge": {
	"title_name": "Revenge",
	"description": "When this character dies, it will deal 1 regular damage per stack to you",
	"image": preload("res://assets/images/status/revenge.png"),
	"intent_title": "Revengeance",
	"in-text_name": "revenge"},
   "soulbind": {
	"title_name": "Soulbind",
	"description": "When this character dies, any damage dealt that exceeded his life will return 4 times as regular damage",
	"image": preload("res://assets/images/status/soulbind.png"),
	"intent_title": "Binding soul",
	"in-text_name": "soulbind"},
   "splitting": {
	"title_name": "Splitting",
	"description": "When this character dies, it will divide into two",
	"image": preload("res://assets/images/status/splitting.png"),
	"intent_title": "Mitosis",
	"in-text_name": "splitting"},
   "temp_strength": {
	"title_name": "Temporary Buff",
	"description": "Increases the damage of this character next attack in recipes",
	"image": preload("res://assets/images/status/temp_strength.png"),
	"intent_title": "Focusing strength",
	"in-text_name": "temporary buff"},
   "time_bomb": {
	"title_name": "Time Bomb",
	"description": "Player will draw unstable reagents",
	"image": preload("res://assets/images/status/time_bomb.png"),
	"intent_title": "Planting Bomb",
	"in-text_name": "time bomb"},
   "tough": {
	"title_name": "Tough Skin",
	"description": "Shield isn't removed at the end of turn",
	"image": preload("res://assets/images/status/tough.png"),
	"intent_title": "Toughing Up",
	"in-text_name": "tough"},
   "weakness": {
	"title_name": "Weak",
	"description": "This character deals 1/3 less attack damage. Decreases every turn",
	"image": preload("res://assets/images/status/weakness.png"),
	"intent_title": "Weakening",
	"in-text_name": "weakness"},
}

static func get_all_status() -> Dictionary:
	return STATUSES

static func get_from_name(name: String) -> Dictionary:
	if STATUSES.has(name):
		return STATUSES[name]
	else:
		push_error("Given type of status doesn't exist: " + str(name))
		assert(false)
		return {}
