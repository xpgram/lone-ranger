shader_type canvas_item;

// [TODO] Remove this file.

#include "res://utilities/shaders/pixelize.gdshaderinc"


void fragment() {
  vec2 grid_uv = pixelate(SCREEN_UV);
  COLOR = texture(TEXTURE, grid_uv);
}
