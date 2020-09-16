extends CanvasLayer

signal continued

onready var default_position = $DefaultPosition
onready var title = $Control/Title
onready var recipes = $Control/Recipes

const DEFAULT_DURATION = 1
const MESSAGE = preload("res://game/ui/Message.tscn")
const RECIPE_DISPLAY = preload("res://game/recipe-book/RecipeDisplay.tscn")

var message_stack := []
var message_height : float


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

	var display = RECIPE_DISPLAY.instance()
	$Control/Recipes.add_child(display)
	display.set_combination(combination)
	
	title.text = "Mastered Recipe!"

func new_recipe_discovered(combination: Combination):
	$Control.show()

	var display = RECIPE_DISPLAY.instance()
	$Control/Recipes.add_child(display)
	display.set_combination(combination)
	
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


func _on_message_disappeared(message: Message):
	message_stack.erase(message)
	message.queue_free()
	if message_stack.empty():
		set_process(false)


func _on_Continue_pressed():
	$Control.hide()
	for display in $Control/Recipes.get_children():
		$Control/Recipes.remove_child(display)
	
	emit_signal("continued")
