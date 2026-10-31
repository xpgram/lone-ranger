shader_type canvas_item;

#include "res://utilities/shaders/quantize_colors.gdshaderinc"
#include "res://utilities/shaders/cutoff_filter.gdshaderinc"
#include "res://utilities/shaders/color_invert.gdshaderinc"
#include "res://utilities/shaders/gradient_color_replace.gdshaderinc"
#include "res://utilities/shaders/accumulative_blur.gdshaderinc"


uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR = quantize_colors(COLOR);
	COLOR = cutoff_filter(COLOR);
	COLOR = color_invert(SCREEN_UV, COLOR);
	COLOR = gradient_color_replace(SCREEN_UV, COLOR);
	COLOR = accumulative_blur(SCREEN_UV, COLOR);
}
