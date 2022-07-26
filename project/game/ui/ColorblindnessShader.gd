extends CanvasLayer

enum COLORBLIND_MODES {PROTANOPIA, DEUTRANOPIA, TRITANOPIA}

func set_mode(value):
	assert(value >= 0 and value < COLORBLIND_MODES.size(), "Not a valid colorblind mode: " + str(value))
	$Shader.material.set_shader_param("mode", value)


func enable():
	$Shader.material.set_shader_param("intensity", 1.0)


func disable():
	$Shader.material.set_shader_param("intensity", 0.0)
