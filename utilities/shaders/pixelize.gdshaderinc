// [TODO] Move the player's UI stuff above the viewport (out of the player module).
//     This stops the shader from micro-adjusting the UI, or pixelizing it.
//     How, uh... how do I do this?
//     I may want to apply an independent shader set to it. Pixelation at a higher resolution, maybe?
//     So, do we put them under a different viewport?
//     Do we just assemble the elements literally above the main viewport? How do we match
//     the output dimensions?
// [TODO] Is it better to import a gdshaderinc? Or to have a "second pass" shader set?
//     Is it easy to include a second pass?
//     Is there any performance overhead for having a second pass instead of an include?
//     If done right, no, and it should solve the namespace collision problem that shader
//     includes have naturally.
//
// [TODO] Try out MaterialLayers, see if it makes the shader mashing simple enough.

// This uniform auto-captures the screen texture.
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;


group_uniforms Pixelation;

uniform bool enable = true;

// The resolution of the pixelation grid. This should match the intended resolution of the
// rendered image with no rotation applied.
uniform vec2 grid_resolution = vec2(240, 160);

// The translation offset of the pixelation grid.
// IMPLEMENT Not yet implemented. This is supposed to smooth out subpixel movement.
uniform vec2 grid_offset = vec2(0.0);

// The angle in radians of the pixelation grid.
uniform float grid_rotation = 0.0;

// The point on the texture that the pixel grid is rotated about.
uniform vec2 grid_rotation_origin = vec2(0.5);


// Returns a matrix that when multiplied with a vector produces a new vector
// rotated by [param angle] radians.
mat2 get_rotation_matrix(float angle){
  float cos_r = cos(angle);
  float sin_r = sin(angle);

  return mat2(
    vec2(cos_r ,-sin_r),
    vec2(sin_r , cos_r)
  );
}


// Returns a new UV from [param uv] quantized to a pixel grid of [param resolution].
vec2 get_pixelated_UV(vec2 uv){
  if (!enable) {
    return uv;
  }

  mat2 rot_cw = get_rotation_matrix(grid_rotation);
  mat2 rot_ccw = transpose(rot_cw);

  // Algorithm:
  // Project the normalized UV into the resolution space, originated about the texture's center.
  vec2 resolution_coords = (uv - grid_rotation_origin) * grid_resolution;
  // Rotate the resolution coordinates into our rotated grid space's frame of reference.
  vec2 rotated_coords = rot_ccw * resolution_coords;
  // Translate the subpixel offset to grid space, where an offset of 1.0 shifts one pixel.
  vec2 pixel_fractional = grid_offset - floor(grid_offset);
  pixel_fractional.x = (pixel_fractional.x < 0.0) ? 1.0 - pixel_fractional.x : pixel_fractional.x;
  pixel_fractional.y = (pixel_fractional.y < 0.0) ? 1.0 - pixel_fractional.y : pixel_fractional.y;
  // Quantize our coordinates, sampling the center-point of the resulting pixel coordinate.
  vec2 rotated_sample_coords = floor(rotated_coords + pixel_fractional) + vec2(0.5);
  // Unrotate our coordinates back into the screen's frame of reference.
  vec2 sample_coords = rot_cw * rotated_sample_coords;
  // Project our resolution coordinates back into a normalized UV, and re-originate about the (0,0) vector.
  vec2 sample_uv = sample_coords / grid_resolution + grid_rotation_origin;

  // Make sure our sample UVs are constrained to the texture space.
  sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));

  return sample_uv;
}
