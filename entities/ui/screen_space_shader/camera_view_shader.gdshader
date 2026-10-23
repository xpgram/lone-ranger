shader_type canvas_item;

#include "res://utilities/shaders/pixelate.gdshaderinc"
#include "res://utilities/shaders/adjust_brightness_level.gdshaderinc"
#include "res://utilities/shaders/quantize_colors.gdshaderinc"
#include "res://utilities/shaders/cutoff_filter.gdshaderinc"
#include "res://utilities/shaders/color_invert.gdshaderinc"
#include "res://utilities/shaders/gradient_color_replace.gdshaderinc"


// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
  vec2 grid_uv = pixelate(SCREEN_UV);

  COLOR = texture(screen_texture, grid_uv);
  COLOR = adjust_brightness_level(COLOR);
  COLOR = quantize_colors(COLOR);
  COLOR = cutoff_filter(COLOR);
  COLOR = color_invert(SCREEN_UV, COLOR);
  COLOR = gradient_color_replace(SCREEN_UV, COLOR);
}
