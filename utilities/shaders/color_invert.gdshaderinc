// Inverts the colors of an image. The strength of the effect per-pixel
// is taken from the [uniform inversion_map]. An fully white inversion_map
// will color invert the entire image.

group_uniforms ColorInvert;

uniform bool color_invert__enable = true;

uniform sampler2D color_invert__inversion_map: repeat_disable, filter_linear, hint_default_white;


vec4 color_invert(vec2 uv, vec4 color) {
  if (!color_invert__enable) {
    return color;
  }

  float strength = texture(color_invert__inversion_map, uv).r;

  if (strength < 0.005) {
    return color;
  }

  vec3 inverted_color = vec3(1.0) - color.rgb;

  color.rgb = mix(color.rgb, inverted_color.rgb, strength);
  return color;
}
