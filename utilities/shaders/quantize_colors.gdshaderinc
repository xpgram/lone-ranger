group_uniforms QuantizeColors;

uniform bool quantize_colors__enable = true;

uniform sampler2D quantize_colors__lightness_map;

// [TODO] Add an input gradient to read color quantizes from?
//   How does this work with colors, do you think? Lightnesses, easy, but colors
//   will require a much larger map, I think. Hm.


float _quantize_colors__quantize_color_channel(float color) {
  // [TODO] Get color's lightness value.
  vec4 lightness_sample = texture(quantize_colors__lightness_map, vec2(color, 0.0));
  float lightness = lightness_sample.r;

  color = lightness;

  return color;
}


vec4 quantize_colors(vec4 color) {
  if (!quantize_colors__enable) {
    return color;
  }

  return vec4(
    _quantize_colors__quantize_color_channel(color.r),
    _quantize_colors__quantize_color_channel(color.g),
    _quantize_colors__quantize_color_channel(color.b),
    color.a
  );
}
