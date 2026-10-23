// Maps a colors channels to a brightness ramp.
// Designed for grayscale and probably less useful otherwise.
// Allows a full spectrum of gray values to be limited to a select few.

group_uniforms QuantizeColors;

uniform bool quantize_colors__enable = true;

uniform sampler2D quantize_colors__lightness_map: filter_nearest;


// Maps a [param color] to a value indicated by the [uniform lightness_map].
float _quantize_colors__quantize_color_channel(float color) {
  vec2 sample_point = vec2(color, 0.0);
  vec4 sample = texture(quantize_colors__lightness_map, sample_point);
  return sample.r;
}


// Returns a color limited to discrete color-channel values as described by the
// lightness map.
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
