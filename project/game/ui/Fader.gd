extends TextureRect

const FADE_SPEED = 30

export var default_shader_offset = .48
export var margin = 80


func update_scroll_fading(scroll_container, dt):
	var v_scroll = scroll_container.get_v_scrollbar()
	var target_value
	if not material.get_shader_param("invert"):
		var max_shader_value = 1.0 - material.get_shader_param("bottom_offset")
		var cur_pos = v_scroll.value + scroll_container.rect_size.y
		var bottom = v_scroll.max_value - margin
		var value = 0
		if cur_pos > bottom: 
			value = (cur_pos - bottom)/float(margin)
		target_value = default_shader_offset*(1.0 - value) + value*max_shader_value
	else:
		var cur_pos = v_scroll.value
		var value = 0
		if cur_pos < margin: 
			value = 1.0 - cur_pos/float(margin)
		target_value = value*default_shader_offset

	material.set_shader_param("top_offset", \
							  lerp(material.get_shader_param("top_offset"), target_value, FADE_SPEED*dt))
