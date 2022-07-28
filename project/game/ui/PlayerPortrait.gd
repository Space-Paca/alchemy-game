extends Node2D

const SPEED = 2
const HEALTHY_COLOR = Color(0.0, 0.9, 0.94)
const MIDLIFE_COLOR = Color(0.9, 0.9, 0.0)
const DYING_COLOR = Color(0.96, 0.13, 0.13)
const PORTRAITS = {
	"alchemist": preload("res://assets/images/ui/book/portraits/alchemist.png"),
	"retro": preload("res://assets/images/ui/book/portraits/retro.png"),
}

onready var bg = $BG
onready var image = $Sprite

var state = "normal"


func _ready():
	if Debug.custom_portrait:
		assert(PORTRAITS.has(Debug.custom_portrait), "Not a valid custom portrait: " + str(Debug.custom_portrait))
		image.texture = PORTRAITS[Debug.custom_portrait]
	else:
		image.texture = PORTRAITS["alchemist"]


func _process(delta):
	var color
	if state == "normal":
		color = HEALTHY_COLOR
	elif state == "danger":
		color = MIDLIFE_COLOR
	elif state == "extreme-danger":
		color = DYING_COLOR
	
	bg.modulate.r += (color.r - bg.modulate.r)*min(SPEED*delta, 1)
	bg.modulate.g += (color.g - bg.modulate.g)*min(SPEED*delta, 1)
	bg.modulate.b += (color.b - bg.modulate.b)*min(SPEED*delta, 1)

func update_visuals(hp, max_hp):
	var percent = hp / float(max_hp)
	if percent > .5:
		set_state("normal")
	elif percent > .2:
		set_state("danger")
	elif percent > .0:
		set_state("extreme-danger")
	else:
		return



func set_state(new_state):
	state = new_state
