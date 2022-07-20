extends HBoxContainer

onready var icon = $Icon
onready var name_label = $Name
onready var made_label = $Made
onready var progress = $MemorizationProgress
onready var current_label = $Amount/Current
onready var total_label = $Amount/Total
onready var new_label = $Icon/New
onready var tween = $Tween

const DURATION = 1

var recipe_id : String
var amount_made : int
var final_amount : int


func _ready():
	set_process(false)
	
	yield(get_tree().create_timer(4.5), "timeout")
	animate_progress()


func _process(_delta):
	current_label.text = str(progress.value)
	if progress.value == final_amount:
		set_process(false)


func set_recipe(id, _amount_made: int, _final_amount: int, new: bool):
	recipe_id = id
	amount_made = _amount_made
	final_amount = _final_amount
	icon.texture = RecipeManager.recipes[recipe_id].fav_icon
	name_label.text = RecipeManager.recipes[recipe_id].name
	made_label.text = str(amount_made)
	new_label.visible = new
	
	var amount = final_amount - amount_made
	var level = Profile.get_recipe_memorized_level(recipe_id)
	var thresholds = Profile.get_memorized_thresholds(recipe_id)
	var threshold = thresholds[level] if level < Profile.MAX_MEMORIZATION_LEVEL\
									  else thresholds[Profile.MAX_MEMORIZATION_LEVEL - 1]
	
	current_label.text = str(amount)
	total_label.text = "/" + str(threshold)
	progress.max_value = threshold
	progress.value = min(amount, threshold)


func animate_progress():
	tween.interpolate_property(progress, "value", null, final_amount, DURATION)
	tween.start()
	set_process(true)
