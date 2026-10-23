// Substitutes the color white and its close relatives for colors taken from
// the substitution texture, or "color map".

group_uniforms WhiteSubstitution;

uniform bool white_substitution__enable = true;

// How strong the substitution effect is. A value of 1.0 is maximally applied.
uniform float white_substitution__mix_ratio: hint_range(0.0, 1.0) = 1.0;

// The curve of the substitution function. A value of 1.0 is a linear function
// of color distance. A value of 2.0 is the distance squared.
// The farther a color is from white, the less it is substituted.
uniform float white_substitution__attenuation: hint_range(0.0, 10.0) = 1.0;

// How close colors must be to be replaced. Beyond this distance, they will
// remain as they are.
uniform float white_substitution__max_distance: hint_range(0.0, 1.0) = 1.0;

// A texture of colors to replace white with. Looks nice when you use gradients.
uniform sampler2D white_substitution__color_map;


// [FIXME] This filter doesn't allow the black filter to be what it wants to.
vec4 white_substitution(vec2 uv, vec4 color) {
  if (!white_substitution__enable) {
    return color;
  }

  const float SQRT_THREE = 1.732051;

  float mix_ratio = clamp(white_substitution__mix_ratio, 0.0, 1.0);
  vec4 white = vec4(1.0);

  vec4 sub_color = texture(white_substitution__color_map, uv);
  float dist = distance(color.rgb, white.rgb);
  float dist_normal = dist / SQRT_THREE;

  if (dist_normal > white_substitution__max_distance) {
    return color;
  }

  float white_ratio = pow(1.0 - dist_normal, white_substitution__attenuation);
  mix_ratio = clamp(white_ratio * mix_ratio, 0.0, 1.0);

  color = mix(color, sub_color, mix_ratio);
  return color;
}
