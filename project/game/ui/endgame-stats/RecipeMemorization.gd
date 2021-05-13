extends HBoxContainer

onready var icon = $Icon
onready var name_label = $Name
onready var progress = $MemorizationProgress
onready var current_label = $Amount/Current
onready var total_label = $Amount/Total
onready var tween = $Tween

const DURATION = 1

var recipe_name : String
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


func set_recipe(_recipe_name: String, _amount_made: int, _final_amount: int):
	recipe_name = _recipe_name
	amount_made = _amount_made
	final_amount = _final_amount
	icon.texture = RecipeManager.recipes[recipe_name].fav_icon
	name_label.text = recipe_name
	
	var amount = final_amount - amount_made
	var threshold = Profile.known_recipes[recipe_name].memorized_threshold
	
	current_label.text = str(amount)
	total_label.text = "/" + str(threshold)
	progress.max_value = threshold
	progress.value = amount


func animate_progress():
	tween.interpolate_property(progress, "value", null, final_amount, DURATION)
	tween.start()
	set_process(true)
