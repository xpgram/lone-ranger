shader_type canvas_item;

#include "res://utilities/shaders/pixelate.gdshaderinc"


uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec2 uv = pixelate(SCREEN_UV);
	COLOR = texture(screen_texture, uv);
}
