shader_type canvas_item;

uniform vec2 dimension;
uniform vec2 position;

void fragment(){
	vec2 screen_size = vec2(1.0/1920.0, 1.0/1080.0);
	if (UV.x >= position.x*screen_size.x &&
	    UV.x <= (position.x + dimension.x)*screen_size.x &&
		UV.y >= position.y*screen_size.y &&
	    UV.y <= (position.y + dimension.y)*screen_size.y){
		COLOR = vec4(0,0,0,0);
	}
	else{
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
		COLOR.a = .85;
	}
}