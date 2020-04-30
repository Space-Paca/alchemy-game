shader_type canvas_item;

uniform float grayscale : hint_range(0.0, 1.0);
render_mode unshaded;

void fragment(){
	COLOR = texture(TEXTURE, UV);
	
	if (grayscale > 0.0) {
	    vec3 grey = vec3(dot(COLOR.rgb, vec3(0.299, 0.587, 0.114)));
		COLOR.rgb = COLOR.rgb + grayscale*(grey - COLOR.rgb)
	}
}
