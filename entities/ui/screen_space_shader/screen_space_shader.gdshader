shader_type canvas_item;

#include "res://utilities/shaders/quantize_colors.gdshaderinc"
#include "res://utilities/shaders/adjust_brightness_level.gdshaderinc"


uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	color = adjust_brightness_level(color);
	color = quantize_colors(color);
	
	COLOR = color;
}
