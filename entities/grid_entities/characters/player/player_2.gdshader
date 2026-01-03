shader_type canvas_item;

uniform vec3 gradient_start: source_color;
uniform vec3 gradient_end: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
  //vec2 pos = VERTEX;
  //
  //if (VERTEX.y < 0.0) {
    //VERTEX.x += 20.0;
  //}
}

void fragment() {
  // Load color at fragment
  COLOR = texture(TEXTURE, UV);

  // Define a gradient and get the color for this fragment.
  vec3 gradient_color = mix(gradient_start, gradient_end, UV.y);

  // Apply the gradient color to this fragment, while retaining brightness.
  if (COLOR.a > 0.0) {
    vec3 black = vec3(0.0);
    float white_level = COLOR.r;
    COLOR.rgb = mix(black, gradient_color, white_level);
  }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
