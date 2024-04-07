shader_type canvas_item;

uniform vec4 outline_color : hint_color = vec4(.0, .0, .0, 1.0);
uniform float freq : hint_range(0.0, 20.0);
uniform float fill;

float rand(float x) {
	return fract(sin(x) * 43758.5453);
}

float triangle(float x) {
	return abs(1.0 - mod(abs(x), 2.0)) * 2.0 - 1.0;
}

void fragment() {
	float time = floor(TIME * freq) / 16.0;
	vec2 uv = UV;
	vec2 p = uv;
	vec4 base_color = texture(TEXTURE, uv);
	vec4 color = base_color;
	vec4 edges;
	
	p += vec2(triangle(p.y * rand(time) * 2.0) * rand(time * 0.05) * 0.01,
			triangle(p.x * rand(time * 1.7) * 4.0) * rand(time * 0.05) * 0.01);
	p += vec2(rand(p.x * 3.1 + p.y * 8.7) * 0.01,
			rand(p.x * 1.1 + p.y * 6.7) * 0.01);
	edges = vec4(fill) - (base_color / vec4(texture(TEXTURE, p)));
	color.rgb = vec3(base_color.r);
	color = color / vec4(length(edges));
	color.rbg = vec3(1.0 - max(.0, min(1.0, color.r)));
	color.a = base_color.a * color.r;
	color.rgb *= outline_color.rgb;
	
	
	COLOR = color;
}