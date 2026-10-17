// group_uniform QuantizeColors


// [TODO] Add an input gradient to read color quantizes from?
//   How does this work with colors, do you think? Lightnesses, easy, but colors
//   will require a much larger map, I think. Hm.


float _quantize_colors__quantize_color_channel(float color) {
  float new_color = ceil(color * 5.0 - 1.0) / 4.0;

  if (new_color < 0.5) {
    new_color = 0.0;
  }

  return new_color;
}


vec4 quantize_colors(vec4 color) {
  return vec4(
    _quantize_colors__quantize_color_channel(color.r),
    _quantize_colors__quantize_color_channel(color.g),
    _quantize_colors__quantize_color_channel(color.b),
    color.a
  );
}
