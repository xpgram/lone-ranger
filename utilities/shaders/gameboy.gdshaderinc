#include "res://utilities/shaders/pixelate.gdshaderinc"
#include "res://utilities/shaders/quantize_colors.gdshaderinc"


vec2 gameboy_coord(vec2 uv) {
  uv = pixelate(uv);
  return uv;
}


vec4 gameboy_color(vec4 color) {
  color = quantize_colors(color);
  return color;
}
