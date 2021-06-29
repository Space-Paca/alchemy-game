extends TextureButton

const ALPHA_SPEED = 4
const SCALE_SPEED = 2
const CURSE_SPEED = 5
const LABEL_HOVERED_SCALE = 1.1

var mouse_over := false
var cursed := false


func _ready():
	$CursedContainer.modulate.a = 0
	$Label.modulate.a = 0
	modulate = Color.white


func _process(delta):
	if disabled:
		$Label.modulate.a = max($Label.modulate.a - ALPHA_SPEED*delta, 0)
	else:
		$Label.modulate.a = min($Label.modulate.a + ALPHA_SPEED*delta, 1)
	
	var node = $CursedContainer
	if cursed:
		node.modulate.a = min(node.modulate.a + ALPHA_SPEED*delta, 1)
		modulate.r = max(modulate.r - CURSE_SPEED*delta, .71)
		modulate.g = max(modulate.g - CURSE_SPEED*delta, .33)
	else:
		node.modulate.a = max(node.modulate.a - ALPHA_SPEED*delta, 0)
		modulate.r = min(modulate.r + CURSE_SPEED*delta, 1)
		modulate.g = min(modulate.g + CURSE_SPEED*delta, 1)
		
	
	if mouse_over:
		$Label.rect_scale.x = min($Label.rect_scale.x + SCALE_SPEED*delta, LABEL_HOVERED_SCALE)
		$Label.rect_scale.y = min($Label.rect_scale.y + SCALE_SPEED*delta, LABEL_HOVERED_SCALE)
	else:
		$Label.rect_scale.x = max($Label.rect_scale.x - SCALE_SPEED*delta, 1)
		$Label.rect_scale.y = max($Label.rect_scale.y - SCALE_SPEED*delta, 1)
		

func enable():
	disabled = false
	

func disable():
	mouse_over = false
	disabled = true


func disable_curse():
	cursed = false


func enable_curse():
	cursed = true


func set_curse(cur_value, max_value):
	$CursedContainer/Amount.text = str(cur_value)+"/"+str(max_value)
	

func _on_CombineButton_mouse_entered():
	if not disabled:
		mouse_over = true
		AudioManager.play_sfx("hover_combine_button")

func _on_CombineButton_mouse_exited():
	mouse_over = false
