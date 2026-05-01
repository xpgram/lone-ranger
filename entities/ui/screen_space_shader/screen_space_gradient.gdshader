shader_type canvas_item;

// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform bool pixelize = true;
uniform bool reduced_pixelate = false;
uniform bool just_y = false;
uniform vec2 pixelizer_subpixel_offset = vec2(0.0);
uniform float pixelizer_rotation = 0.0;
uniform vec2 pixelizer_resolution = vec2(240, 160);

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


mat2 get_rotation_matrix(float angle){
  float rad = radians(angle);
  float cos_r = cos(rad);
  float sin_r = sin(rad);
  
  vec2 part1 = vec2(cos_r ,-sin_r);
  vec2 part2 = vec2(sin_r , cos_r);

  return mat2(
    part1,
    part2
  );
}


vec2 get_pixelated_UV(vec2 uv, vec2 resolution, float angle){
  if (!pixelize) {
    return uv;
  }
  
  // FIXME A lower resolution setting for testing purposes.
  if (reduced_pixelate) {
    resolution = vec2(60.0, 40.0);
    // Question: Why does resolution need to be two different numbers?
    // If my rotated pixels are not squares, is this why?
    // My pixels need a standard deviation, not to know the actual screen resolution.
  }
  
  if (just_y) {
    resolution = vec2(resolution.y);
  }

  mat2 rot_cw = get_rotation_matrix(-angle);
  mat2 rot_ccw = get_rotation_matrix(angle);

  // Strategy: Rotate the UV into an imaginary pixel grid, get its pixel group, move the
  // sample point to the middle of that group, and rotate this final sample point back to
  // the texture's original frame of reference.
  vec2 rotated_sample_point = (floor(rot_ccw * uv * resolution) + vec2(0.5)) / resolution;
  vec2 sample_point = rot_cw * rotated_sample_point;
  
  // Make sure our samples are constrained to the texture's sample space.
  sample_point = clamp(sample_point, vec2(0.0), vec2(1.0));

  return sample_point;
}


vec4 apply_fade_in(vec4 color, float progress) {
  // FIXME This function should kick the current color down to the next one in the palette.
  //  But that's not what it does. round() and floor() down there only work via math quirks.

  // Shift the brightness value down proportional to [param progress].
  float white_level = (color.r + FLOAT_ERROR_MARGIN) * progress;

  // Snap the brightness value to one of these values: 0.0, 0.5, 0.75, 1.0.
  if (white_level >= 0.5) {
    white_level = round(white_level * 4.0) / 4.0;
  }
  else {
    white_level = floor(white_level * 2.0) / 2.0;
  }

  // Apply the brightness value.
  color.rgb = vec3(white_level);

  return color;
}


vec4 apply_silhoette(vec4 color, float threshhold, float white_threshhold) {
  // Nudge the thresshold to account for floating-point rounding errors.
  threshhold += FLOAT_ERROR_MARGIN;
  white_threshhold -= FLOAT_ERROR_MARGIN;

  if (color.r <= threshhold) {
    color.rgb = vec3(0.0);
  }
  if (color.r >= white_threshhold) {
    color.rgb = vec3(1.0);
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
  vec2 grid_uv = get_pixelated_UV(SCREEN_UV, pixelizer_resolution, -pixelizer_rotation);
  
  // Load screen-texture color for this fragment.
  COLOR = textureLod(screen_texture, grid_uv, 0.0);

  COLOR = apply_silhoette(COLOR, silhoette_threshhold, silhoette_white_threshhold);
  COLOR = apply_fade_in(COLOR, fade_in_progress);
  COLOR = apply_gradient_to_blacks(COLOR, UV);
}
