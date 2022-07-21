extends HBoxContainer

const DURATION = 1
const BAR_NORMAL_COLOR = Color(0x89ff00ff)
const BAR_MAX_COLOR = Color(0x00f9ffff)

onready var icon = $Icon
onready var name_label = $Name
onready var made_label = $Made
onready var progress = $MemorizationProgress
onready var current_label = $Amount/Current
onready var total_label = $Amount/Total
onready var new_label = $Icon/New
onready var levelup_label = $Amount/Total/LevelUp
onready var memorization_progress = $MemorizationProgress
onready var tween = $Tween

var recipe_id : String
var amount_made : int
var final_amount : int


func _ready():
	memorization_progress.set("custom_styles/fg", memorization_progress.get_stylebox("fg").duplicate(true))


func set_recipe(id, _amount_made: int, _final_amount: int, new: bool, level_up : bool):
	recipe_id = id
	amount_made = _amount_made
	final_amount = _final_amount
	icon.texture = RecipeManager.recipes[recipe_id].fav_icon
	name_label.text = RecipeManager.recipes[recipe_id].name
	made_label.text = str(amount_made)
	new_label.visible = new
	levelup_label.visible = level_up
	
	var level = Profile.get_recipe_memorized_level(recipe_id)
	var thresholds = Profile.get_memorized_thresholds(recipe_id)
	var threshold = thresholds[level] if level < Profile.MAX_MEMORIZATION_LEVEL\
									  else thresholds[Profile.MAX_MEMORIZATION_LEVEL - 1]
	
	var initial_amount = final_amount-amount_made
	current_label.text = str(final_amount)
	total_label.text = "/" + str(threshold)
	progress.max_value = threshold
	progress.value = min(initial_amount, threshold)
	
	if level == Profile.MAX_MEMORIZATION_LEVEL:
		levelup_label.text = tr("MAX_LEVEL")
		memorization_progress.get_stylebox("fg").modulate_color = BAR_MAX_COLOR
	else:
		levelup_label.text = tr("LEVEL_UP")
		memorization_progress.get_stylebox("fg").modulate_color = BAR_NORMAL_COLOR

func animate_progress():
	yield(get_tree().create_timer(4.5), "timeout")
	tween.interpolate_property(progress, "value", null, min(final_amount, progress.max_value), DURATION)
	tween.start()
