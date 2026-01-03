shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec3 gradient_start: source_color;
uniform vec3 gradient_end: source_color;


void fragment() {
  // Load color at fragment
  COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);

  // Define a gradient and get the color for this fragment.
  vec3 gradient_color = mix(gradient_start, gradient_end, UV.y);

  // Apply the gradient color to this fragment, while retaining brightness.
  if (COLOR.a > 0.0) {
    vec3 black = vec3(0.0);
    float white_level = COLOR.r;
    COLOR.rgb = mix(black, gradient_color, white_level);
  }
}
