extends HBoxContainer

onready var icon = $Icon
onready var name_label = $Name
onready var progress = $MemorizationProgress
onready var current_label = $Amount/Current
onready var total_label = $Amount/Total


func _ready():
	pass


func set_recipe(recipe: Recipe):
	icon.texture = recipe.fav_icon
	name_label.text = recipe.name
	
	
