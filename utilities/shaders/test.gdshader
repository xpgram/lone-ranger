shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

float quantize(float n) {
  float m = ceil(n * 4.0) / 4.0;
  if (m < 0.5) {
    m = 0.0;
  }
  return m;
}

void fragment() {
  float red = mod(UV.x, 0.25) * 4.0;
  float green = UV.y;
  float blue = ceil(UV.x * 4.0) / 4.0;

  red = quantize(red);
  green = quantize(green);
  blue = quantize(blue);

	COLOR = vec4(red, green, blue, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
