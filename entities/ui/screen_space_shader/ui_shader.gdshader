shader_type canvas_item;


#include "res://utilities/shaders/pixelate.gdshaderinc"


// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec2 pixelated_uv = pixelate(SCREEN_UV);

	COLOR = texture(screen_texture, pixelated_uv);
}
