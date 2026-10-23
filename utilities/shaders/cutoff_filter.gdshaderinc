// Used to crudely cut a color channel's middle values out.
// The crush_ranges describe how much of the normalized color spectrum is
// affected, where black forces the middle values to black, and white likewise
// white.
//
// NOTE: The name CutoffFilter may be a misnomer. Previously, this was known as
// the silhoette filter.

group_uniforms CutoffFilter;

uniform bool cutoff_filter__enable = true;

// How far from the black end of the spectrum that colors will be
// crushed to black.
uniform float cutoff_filter__black_crush_range: hint_range(0.0, 1.0) = 0.0;

// How far from the white end of the spectrum that colors will be
// crushed to white.
uniform float cutoff_filter__white_crush_range: hint_range(0.0, 1.0) = 0.0;


float _cutoff_filter__apply_filter(float color_channel) {
  float white_crush_threshhold = 1.0 - cutoff_filter__white_crush_range;

  if (color_channel <= cutoff_filter__black_crush_range) {
    color_channel = 0.0;
  }
  if (color_channel >= white_crush_threshhold) {
    color_channel = 1.0;
  }
  return color_channel;
}


vec4 cutoff_filter(vec4 color) {
  if (!cutoff_filter__enable) {
    return color;
  }

  return vec4(
    _cutoff_filter__apply_filter(color.r),
    _cutoff_filter__apply_filter(color.g),
    _cutoff_filter__apply_filter(color.b),
    color.a
  );
}
