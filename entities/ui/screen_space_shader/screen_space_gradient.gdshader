shader_type canvas_item;

// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

// How "faded-in" the screen is. At 0.0, the screen is completely black, and at 1.0, it is
// fully rendered.
uniform float fade_in_progress: hint_range(0.0, 1.0) = 1.0;

// The color-crush threshhold. Fragment brightness values above this value will be
// rendered unaltered, values equal or below will be black.
uniform float silhoette_threshhold: hint_range(0.0, 1.0) = 0.0;

// The gradient color key at the top of the screen.
uniform vec3 gradient_start: source_color = vec3(1.0);

// The gradient color key at the bottom of the screen.
uniform vec3 gradient_end: source_color = vec3(1.0);

// Whether to invert the brightness value of the fragment color.
uniform bool invert_colors = false;


vec4 apply_fade_in(vec4 color, float progress) {
  // Shift the brightness value down proportional to [param progress].
  float white_level = color.r * progress;

  // Snap the brightness value to one of these values: 0.0, 0.5, 0.75, 1.0.
  if (white_level > 0.5) {
    white_level = round(white_level * 4.0) / 4.0;
  }
  else {
    white_level = round(white_level * 2.0) / 2.0;
  }

  // Apply the brightness value.
  color.rgb = vec3(white_level);

  return color;
}


vec4 apply_silhoette(vec4 color, float threshhold) {
  if (color.r <= threshhold) {
    color.rgb = vec3(0.0);
  }

  return color;
}


vec4 apply_gradient_to_blacks(vec4 color, vec2 uv) {
  // Define a gradient and get the color for this fragment.
  vec3 gradient_color = mix(gradient_start, gradient_end, uv.y);

  if (color.a > 0.0) {
    vec3 black = vec3(0.0);
    float white_level = color.r;

    if (!invert_colors) {
      color.rgb = mix(black, gradient_color, white_level);
    }
    else {
      color.rgb = mix(gradient_color, black, white_level);
    }
  }

  return color;
}


void fragment() {
  // Load screen-texture color for this fragment.
  COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);

  COLOR = apply_fade_in(COLOR, fade_in_progress);
  COLOR = apply_silhoette(COLOR, silhoette_threshhold);
  COLOR = apply_gradient_to_blacks(COLOR, UV);
}
