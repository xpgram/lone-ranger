shader_type canvas_item;

uniform bool enable = true;

// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

// The resolution of the pixelation grid. This should match the intended resolution of the
// rendered image with no rotation applied.
uniform vec2 pixel_grid_resolution = vec2(240, 160);

// The angle in degrees of the pixelation grid.
uniform float pixel_grid_rotation_deg = 0.0;

// The translation offset of the pixelation grid.
// IMPLEMENT Not yet implemented. This is supposed to smooth out subpixel movement.
uniform vec2 subpixel_offset = vec2(0.0);


//
mat2 get_rotation_matrix(float angle){
  float rad_angle = radians(angle);
  float cos_r = cos(rad_angle);
  float sin_r = sin(rad_angle);

  return mat2(
    vec2(cos_r ,-sin_r),
    vec2(sin_r , cos_r)
  );
}


//
vec2 get_pixelated_UV(vec2 uv, vec2 resolution, float angle){
  if (!enable) {
    return uv;
  }

  mat2 rot_cw = get_rotation_matrix(-angle);
  mat2 rot_ccw = transpose(rot_cw);

  // Algorithm:
  // Translate the subpixel offset to grid space, where an offset of 1.0 shifts one pixel.
  vec2 pixel_fractional = mod(subpixel_offset - vec2(0.5), 1.0) / resolution;
  // Project the normalized UV into the resolution space.
  vec2 resolution_coords = (uv + pixel_fractional) * resolution;
  // Rotate the resolution coordinates into our rotated grid space's frame of reference.
  vec2 rotated_coords = rot_ccw * resolution_coords;
  // Quantize our coordinates, taking the center as our sample point.
  vec2 rotated_sample_coords = floor(rotated_coords) + vec2(0.5);
  // Unrotate our coordinates back into the screen's frame of reference.
  vec2 sample_coords = rot_cw * rotated_sample_coords;
  // Project our resolution coordinates back into a normalized UV.
  vec2 sample_uv = sample_coords / resolution;

  // Make sure our sample UVs are constrained to the texture space.
  sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));

  return sample_uv;
}


void fragment() {
  vec2 grid_uv = get_pixelated_UV(SCREEN_UV, pixel_grid_resolution, -pixel_grid_rotation_deg);

  COLOR = texture(TEXTURE, grid_uv);
}
