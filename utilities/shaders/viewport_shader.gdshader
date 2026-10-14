shader_type canvas_item;

#include "res://utilities/shaders/pixelize.gdshaderinc"


void fragment() {
  vec2 grid_uv = get_pixelated_UV(SCREEN_UV);
  COLOR = texture(TEXTURE, grid_uv);
}
