// Substitutes the color black and its close relatives for colors taken from
// the substitution texture, or "color map".

group_uniforms BlackSubstitution;

uniform bool black_substitution__enable = true;

// How strong the substitution effect is. A value of 1.0 is maximally applied.
uniform float black_substitution__mix_ratio: hint_range(0.0, 1.0) = 1.0;

// The curve of the substitution function. A value of 1.0 is a linear function
// of color distance. A value of 2.0 is the distance squared.
// The farther a color is from black, the less it is substituted.
uniform float black_substitution__attenuation: hint_range(0.0, 10.0) = 1.0;

// How close colors must be to be replaced. Beyond this distance, they will
// remain as they are.
uniform float black_substitution__max_distance: hint_range(0.0, 1.0) = 1.0;

// A texture of colors to replace black with. Looks nice when you use gradients.
uniform sampler2D black_substitution__color_map;


vec4 black_substitution(vec2 uv, vec4 color) {
  if (!black_substitution__enable) {
    return color;
  }

  const float SQRT_THREE = 1.732051;

  float mix_ratio = clamp(black_substitution__mix_ratio, 0.0, 1.0);
  vec4 black = vec4(vec3(0.0), 1.0);

  vec4 sub_color = texture(black_substitution__color_map, uv);
  float dist = distance(color.rgb, black.rgb);
  float dist_normal = dist / SQRT_THREE;

  if (dist_normal > black_substitution__max_distance) {
    return color;
  }

  float black_ratio = pow(1.0 - dist_normal, black_substitution__attenuation);
  mix_ratio = clamp(black_ratio * mix_ratio, 0.0, 1.0);

  color = mix(color, sub_color, mix_ratio);
  return color;
}
