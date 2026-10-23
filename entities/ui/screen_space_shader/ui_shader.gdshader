shader_type canvas_item;

#include "res://utilities/shaders/pixelate.gdshaderinc"
#include "res://utilities/shaders/adjust_brightness_level.gdshaderinc"
#include "res://utilities/shaders/quantize_colors.gdshaderinc"


uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec2 grid_uv = pixelate(SCREEN_UV);

	COLOR = texture(screen_texture, grid_uv);
	COLOR = adjust_brightness_level(COLOR);
	COLOR = quantize_colors(COLOR);
}
