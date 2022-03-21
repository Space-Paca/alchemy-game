extends TextureRect

export var default_shader_offset = .48
export var margin = 80

func update_scroll_fading(scroll_container):
	var v_scroll = scroll_container.get_v_scrollbar()
	var max_shader_value = 1.0 - material.get_shader_param("bottom_offset")
	var cur_pos = v_scroll.value + scroll_container.rect_size.y
	var bottom = v_scroll.max_value - margin
	var value = 0
	if cur_pos > bottom: 
		value = (cur_pos - bottom)/float(margin)
	var shader_value = default_shader_offset*(1.0 - value) + value*max_shader_value
	material.set_shader_param("top_offset", shader_value)
