// Blends the previously rendered frame with the current one. When used subtly,
// produces old LCD screen-like effects.
//
// NOTE: This shader only works if the uniform last_frame is continuously
// updated by the game logic.

group_uniforms AccumulativeBlur;


uniform bool accumulative_blur__enable = true;

// The noramlized mix ratio between the current and last frames.
// Values closer to 1.0 produce much stronger blending effects.
uniform float accumulative_blur__mix_ratio: hint_range(0.0, 1.0) = 0.25;

// The previously rendered frame that should be blended with the current one.
// The game logic should continuously update this field.
uniform sampler2D accumulative_blur__last_frame: repeat_disable, filter_nearest, hint_default_transparent;

// Whether the last_frame uniform has been assigned or not.
// The game logic should flip this on once during scene setup.
uniform bool accumulative_blur__sampler_is_valid = false;

// [FIXME] Implement frame delta adjustment so that 60 fps and 120 fps result in equivalent blurs.
//   I just gotta work out the math a bit.
uniform float accumulative_blur__frame_delta = 0.0;


vec4 accumulative_blur(vec2 uv, vec4 color) {
  if (
      !accumulative_blur__enable
      || !accumulative_blur__sampler_is_valid
  ) {
    return color;
  }

  vec4 last_frame_color = texture(accumulative_blur__last_frame, uv);
  float mix_ratio = accumulative_blur__mix_ratio;
  mix_ratio = (mix_ratio >= 0.005) ? mix_ratio : 0.0;
  mix_ratio = clamp(mix_ratio, 0.0, 1.0);

  color = mix(color, last_frame_color, mix_ratio);
  return color;
}
