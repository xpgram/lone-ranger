shader_type canvas_item;

// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform bool pixelize = true;
uniform vec2 pixelizer_subpixel_offset = vec2(0.0);
uniform float pixelizer_rotation = 0.0;

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


vec2 rotate(vec2 uv, vec2 pivot, float angle) {
  angle += (PI / 2.0);

  mat2 rotation = mat2(
    vec2(sin(angle), -cos(angle)),
    vec2(cos(angle), sin(angle))
  );
  uv -= pivot;
  uv *= rotation;
  uv += pivot;
  return uv;
}


vec2 get_pixelated_uv(vec2 uv, vec2 resolution) {
  if (!pixelize) {
    return uv;
  }
  
  // Okay, I know why this isn't working.
  //
  // I need to remember that the square area of the final image I'm trying to fill does
  // not move. If all those points sample the same spot, they'll all be the same color.
  // I need to map an area to an area.
  //
  // What I'm actually trying to do is something like this, I think:
  //
  // 1. The camera can already rotate the image. In fact, it's better because it can
  //    reveal parts of the world otherwise not seen; a shader can't do this.
  // 2. The pixelation method _must_ consider skewed grid lines. This means truncation
  //    absolutely cannot work.
  // 3. If we can pixelate into diamonds (rotated squares), then we simply do so using the
  //    camera's rotation. With a little nudging to make sure these rotated lines still
  //    align with the source image, everything should work out.
  //
  // How to pixelate into a rotated 'screen' is... not something I know how to do, though.
  // But, it's kind of like splitting a vector into many segments, isn't it? In fact,
  // that's exactly what it is. And it is known how to segment a vector.
  //
  // I need to look into the math for moving a point along a vector, or relengthening a
  // vector maybe. The answer should be easier to see once we're there.
  
  // Also, I haven't figured out that subpixel camera movement thing either. I assume it's
  // a similar complaint, though: I'm forgetting that the square on the image I'm trying
  // to fill does not move.
  //
  // The strategy I've heard of rendering just a little extra and micro adjusting the
  // canvas to accomodate the camera's subpixel position is really just a trick for moving
  // the pixel grid lines. So, as with the above note, if I control where the grid lines
  // are, then I can get smooth camera movement.
  //
  // The problem I'm trying to solve, and this does sound irritating, is that I have a
  // grid established in the game already, just by how things are laid out, and my
  // pixelation method needs to match the lines that already exist.
  
  vec2 grid_uv = uv;
  
  // Apply pixelation.
  grid_uv = round(uv * resolution) / resolution;
  grid_uv += vec2(0.5, 0.5) / resolution;
  grid_uv -= pixelizer_subpixel_offset / resolution;

  // Rotate the pixel grid.
  float rot_rad = pixelizer_rotation / 180.0 * PI;
  grid_uv = rotate(grid_uv, vec2(0.5), -rot_rad);

  return grid_uv;
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
  vec2 grid_uv = get_pixelated_uv(SCREEN_UV, vec2(240, 160));
  
  // Load screen-texture color for this fragment.
  COLOR = textureLod(screen_texture, grid_uv, 0.0);

  COLOR = apply_silhoette(COLOR, silhoette_threshhold, silhoette_white_threshhold);
  COLOR = apply_fade_in(COLOR, fade_in_progress);
  COLOR = apply_gradient_to_blacks(COLOR, UV);
}
