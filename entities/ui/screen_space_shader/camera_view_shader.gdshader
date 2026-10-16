shader_type canvas_item;

#include "res://utilities/shaders/pixelate.gdshaderinc"
#include "res://utilities/shaders/quantize_colors.gdshaderinc"


// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

// How "faded-in" the screen is. At 0.0, the screen is completely black, and at 1.0, it is
// fully rendered.
uniform float fade_in_progress: hint_range(0.0, 1.0) = 1.0;

// The color-crush threshhold for grays to black. Fragment brightness values above this
// value will be rendered unaltered, values equal or below will be black.
uniform float silhoette_threshhold: hint_range(0.0, 1.0) = 0.0;

// The color-crush threshhold for grays to white. Fragment brightness values below this
// value will be rendered unaltered, values equal or above will be white.
uniform float silhoette_white_threshhold: hint_range(0.0, 1.0) = 1.0;

// The gradient color key at the top of the screen.
uniform vec3 gradient_start: source_color = vec3(1.0);

// The gradient color key at the bottom of the screen.
uniform vec3 gradient_end: source_color = vec3(1.0);

// Whether to invert the brightness value of the fragment color.
uniform bool invert_colors = false;

// An 'infinitesimal' amount to adjust float limits by to account for rounding errors.
const float FLOAT_ERROR_MARGIN = 0.005;



vec4 apply_fade_in(vec4 color, float progress) {
  color.rgb *= progress;
  return color;
}


float apply_white_black_thresshold(float n, float black_threshhold, float white_threshhold) {
  if (n <= black_threshhold) {
    n = 0.0;
  }
  if (n >= white_threshhold) {
    n = 1.0;
  }
  return n;
}


vec4 apply_silhoette(vec4 color, float threshhold, float white_threshhold) {
  return vec4(
    apply_white_black_thresshold(color.r, threshhold, white_threshhold),
    apply_white_black_thresshold(color.g, threshhold, white_threshhold),
    apply_white_black_thresshold(color.b, threshhold, white_threshhold),
    color.a
  );
}


vec4 apply_gradient_to_blacks(vec4 color, vec2 uv) {
  // Define a gradient and get the color for this fragment.
  vec3 gradient_color = mix(gradient_start, gradient_end, uv.y);

  // This gradient color trick is only applied to grayscale colors.
  float grayness = (2.0*color.r - color.g - color.b);
  if (grayness > FLOAT_ERROR_MARGIN) {
    return color;
  }

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
  vec2 grid_uv = pixelate(SCREEN_UV);

  // Load screen-texture color for this fragment.
  COLOR = texture(screen_texture, grid_uv);

  COLOR = apply_silhoette(COLOR, silhoette_threshhold, silhoette_white_threshhold);
  COLOR = apply_fade_in(COLOR, fade_in_progress);
  COLOR = quantize_colors(COLOR);
  COLOR = apply_gradient_to_blacks(COLOR, UV);
}
