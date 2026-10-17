group_uniforms AdjustBrightness;

uniform bool adjust_brightness__enable = true;

// A multiple of the image's brightness value. A value of 1.0 is neutral
// and will not result in any changes.
uniform float adjust_brightness__coefficient = 1.0;

//
uniform int adjust_brightness__levels = 5;


vec4 adjust_brightness_level(vec4 color) {
  if (!adjust_brightness__enable) {
    return color;
  }

  float coefficient = adjust_brightness__coefficient;
  float levels = float(adjust_brightness__levels);
  coefficient = round(coefficient * levels) / levels;

  color.rgb *= coefficient;
  color = clamp(color, vec4(0.0), vec4(1.0));
  return color;
}
