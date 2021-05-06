extends HBoxContainer

onready var icon = $Icon
onready var name_label = $Name
onready var progress = $MemorizationProgress
onready var current_label = $Amount/Current
onready var total_label = $Amount/Total
onready var tween = $Tween

const DURATION = 1

var recipe_name : String


func _ready():
	set_process(false)


func _process(_delta):
	current_label.text = str(progress.value)


func set_recipe(_recipe_name: String):
	recipe_name = _recipe_name
	icon.texture = RecipeManager.recipes[recipe_name].fav_icon
	name_label.text = recipe_name
	
	var amount = Profile.known_recipes[recipe_name]["amount"] -\
			Profile.known_recipes[recipe_name]["made_in_run"]
	var threshold = Profile.known_recipes[recipe_name]["memorized_threshold"]
	
	current_label.text = str(amount)
	total_label.text = "/" + str(threshold)
	progress.max_value = threshold
	progress.value = amount


func animate_progress():
	var final_amount = Profile.known_recipes[recipe_name]["amount"]
	
	tween.interpolate_property(progress, "value", null, final_amount, DURATION)
	tween.start()
	set_process(true)
	
	yield(tween, "tween_completed")
	set_process(false)
