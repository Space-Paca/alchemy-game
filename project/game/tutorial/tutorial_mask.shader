shader_type canvas_item;

uniform vec2 dimension;
uniform vec2 position;

void fragment(){
	
	if (SCREEN_UV.x >= position.x*SCREEN_PIXEL_SIZE.x &&
	    SCREEN_UV.x <= (position.x + dimension.x)*SCREEN_PIXEL_SIZE.x &&
		1.0 - SCREEN_UV.y >= position.y*SCREEN_PIXEL_SIZE.y &&
	    1.0 - SCREEN_UV.y <= (position.y + dimension.y)*SCREEN_PIXEL_SIZE.y){
		COLOR = vec4(0,0,0,0)
	}
	else{
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
		COLOR.a = .85;
	}
}