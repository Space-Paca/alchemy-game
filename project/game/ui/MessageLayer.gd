extends CanvasLayer

signal continued
signal favorite_recipe

onready var default_position = $DefaultPosition
onready var title = $Control/Title
onready var recipes = $Control/Recipes
onready var arrow = $Control/Arrow
onready var continue_button = $Control/Buttons/Continue
onready var favorite_button = $Control/Buttons/FavoriteRecipe
onready var favorite_error_label = $Control/Buttons/FavoriteRecipe/FavoriteError

const DEFAULT_DURATION = 1
const MESSAGE = preload("res://game/ui/Message.tscn")
const RECIPE_DISPLAY = preload("res://game/recipe-book/RecipeDisplay.tscn")

var message_stack := []
var message_height : float
var current_combination


func _ready():
	$Control.hide()
	var message = MESSAGE.instance()
	message_height = message.rect_size.y
	message.queue_free()
	set_process(false)


func _process(_delta):
	for i in range(message_stack.size()):
		message_stack[i].rect_position.y = lerp(message_stack[i].rect_position.y,
				message_height * i, .1)

func recipe_mastered(combination: Combination):
	AudioManager.play_sfx("recipe_mastered")
	$Control.show()
	
	current_combination = combination
	
	favorite_button.show()
	favorite_error_label.hide()
	favorite_button.text = "Favorite this Recipe"
	favorite_button.disabled = false
	
	var display_normal = RECIPE_DISPLAY.instance()
	$Control/Recipes.add_child(display_normal)
	display_normal.set_combination(combination)
	display_normal.preview_mode(false)
	var display_mastered = RECIPE_DISPLAY.instance()
	$Control/Recipes.add_child(display_mastered)
	display_mastered.set_combination(combination)
	display_mastered.preview_mode(true)
	
	arrow.show()
	
	title.text = "Mastered Recipe!"

func new_recipe_discovered(combination: Combination):
	$Control.show()
	
	arrow.hide()
	favorite_button.hide()
	
	var display = RECIPE_DISPLAY.instance()
	$Control/Recipes.add_child(display)
	display.set_combination(combination)
	display.preview_mode(false)
	
	title.text = "Discovered New Recipe!"

func add_message(text: String, duration: float = DEFAULT_DURATION):
	var message : Message = MESSAGE.instance()
# warning-ignore:return_value_discarded
	message.connect("disappeared", self, "_on_message_disappeared")
	default_position.add_child(message)
	message.set_text(text)
	message.rect_position.y = message_height * message_stack.size()
	message.animate(duration)
	message_stack.append(message)
	set_process(true)


func exit():
	$Control.hide()
	arrow.hide()
	for display in $Control/Recipes.get_children():
		$Control/Recipes.remove_child(display)
	emit_signal("continued")

func favorite_error():
	favorite_button.text = "Unavailable favorite slot"
	favorite_error_label.show()

func _on_message_disappeared(message: Message):
	message_stack.erase(message)
	message.queue_free()
	if message_stack.empty():
		set_process(false)


func _on_Continue_pressed():
	exit()


func _on_OpenRecipes_pressed():
	exit()



func _on_button_mouse_entered():
	AudioManager.play_sfx("click")


func _on_FavoriteRecipe_pressed():
	favorite_button.text = "Favorited!"
	favorite_button.disabled = true
	emit_signal("favorite_recipe", current_combination)
