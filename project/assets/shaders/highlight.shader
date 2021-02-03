shader_type canvas_item;
render_mode unshaded;

uniform float grayscale : hint_range(0.0, 1.0);
uniform float highlight_thickness : hint_range(0, 15) = 0.0;
uniform vec4 highlight_color : hint_color = vec4(1);

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	
	// Grayscale
	vec3 gray = vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114)));
	color.rgb = color.rgb + grayscale*(gray - color.rgb);
	
	// Outline
	vec2 size = TEXTURE_PIXEL_SIZE * highlight_thickness / 2.0;
	
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);
	
	COLOR = mix(color, highlight_color, outline - color.a);
}
