// A shader to replace colors with textures.
//
// Similar to palette swapping, but replacements do not have to be single
// color-to-color operations. For instance, the color black can be replaced
// with a conic, rainbow gradient.
//
// Note that the palette swapping done here is based on color luminance
// specifically and does not properly account for the full color spectrum.
//
// The shader supports two replacement textures, with the mix between them
// modulated by a CurveTexture, and the mix strength of this effect being
// modulated by a separate CurveTexture.

group_uniforms GradientColorReplace;

uniform bool gradient_color_replace__enable = true;

// Whether to use the faster but lower quality luminance measurement function.
// The faster one just takes the average of the color channels. The quality one
// is a weighted pythagorean distance function.
uniform bool gradient_color_replace__fast_luminance = true;

// How strong the gradient effect is at various color-brightness levels.
uniform sampler2D gradient_color_replace__saturation_curve: repeat_disable, filter_linear, hint_default_black;

// How strong the preference for texture A over texture B is at various
// color-brightness levels. A value of 0.0 (or black) will prefer an unmixed
// texture A, whereas 1.0 (or white) will prefer texture B.
uniform sampler2D gradient_color_replace__ab_mix_curve: repeat_disable, filter_linear, hint_default_black;

// The A-side texture to replace colors with.
uniform sampler2D gradient_color_replace__texture_a: repeat_disable, filter_linear, hint_default_white;

// The B-side texture to replace colors with.
uniform sampler2D gradient_color_replace__texture_b: repeat_disable, filter_linear, hint_default_white;


vec4 gradient_color_replace(vec2 uv, vec4 color) {
  if (!gradient_color_replace__enable) {
    return color;
  }

  float luminance = 0.0;

  if (gradient_color_replace__fast_luminance) {
    luminance = (color.r + color.g + color.b) / 3.0;
  }
  else {
    luminance = sqrt(
      pow(0.299 * color.r, 2.0)
      + pow(0.587 * color.g, 2.0)
      + pow(0.114 * color.b, 2.0)
    );
  }

  vec2 luminance_uv = vec2(luminance, 0.0);
  float effect_strength = texture(gradient_color_replace__saturation_curve, luminance_uv).r;

  if (effect_strength < 0.005) {
    return color;
  }

  vec4 sample_a = texture(gradient_color_replace__texture_a, uv);
  vec4 sample_b = texture(gradient_color_replace__texture_b, uv);

  float ab_mix = texture(gradient_color_replace__ab_mix_curve, luminance_uv).r;
  vec4 sample_color = mix(sample_a, sample_b, ab_mix);

  color = mix(color, sample_color, effect_strength);
  return color;
}
