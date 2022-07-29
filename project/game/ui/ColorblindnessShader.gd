extends CanvasLayer

enum COLORBLIND_MODES {PROTANOPIA, DEUTRANOPIA, TRITANOPIA}

const MODES_NAME =  ["PROTANOPIA", "DEUTRANOPIA", "TRITANOPIA"]
const SPEED = 2.5


func _ready():
	$Shader.material.set_shader_param("intensity", 0.0)


func set_mode(value):
	assert(value >= 0 and value < COLORBLIND_MODES.size(), "Not a valid colorblind mode: " + str(value))
	$Shader.material.set_shader_param("mode", value)


func enable():
	var cur = $Shader.material.get_shader_param("intensity")
	if cur < 1.0:
		$Tween.remove_all()
		$Tween.interpolate_property($Shader.material, "shader_param/intensity",\
									null, 1.0, (1.0 - cur)/SPEED, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()


func disable():
	var cur = $Shader.material.get_shader_param("intensity")
	if cur > 0.0:
		$Tween.remove_all()
		$Tween.interpolate_property($Shader.material, "shader_param/intensity",\
									null, 0.0, cur/SPEED, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()
