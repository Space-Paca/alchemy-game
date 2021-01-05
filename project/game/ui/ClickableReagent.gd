extends TextureButton

const SPEED = 7

var active = false

func _ready():
	$Active.modulate.a = 0

func _process(dt):
	if active:
		$Active.modulate.a = min($Active.modulate.a + SPEED*dt, 1)
	else:
		$Active.modulate.a = max($Active.modulate.a - SPEED*dt, 0)

func activate():
	active = true
	disabled = true


func deactivate():
	active = false
	disabled = false


func setup(reagent_texture, upgraded):
	$Reagent.texture = reagent_texture
	if upgraded:
		$Upgraded.show()
	else:
		$Upgraded.hide()
