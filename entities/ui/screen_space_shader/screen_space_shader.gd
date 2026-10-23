## An API script for the screen space ColorRect's shader parameters.
class_name PlayerScreenSpaceShader
extends ColorRect


## The black cutoff threshhold. At a value of 0.0, no colors will be
## crushed to black.
var black_cutoff_range: float = 0.0:
  get():
    return material.get_shader_parameter('cutoff_filter__black_crush_range');
  set(value):
    material.set_shader_parameter('cutoff_filter__black_crush_range', value);


## The white cutoff thresshold. At a value of 0.0, no colors will be
## crushed to white.
var white_cutoff_range: float = 0.0:
  get():
    return material.get_shader_parameter('cutoff_filter__white_crush_range');
  set(value):
    material.set_shader_parameter('cutoff_filter__white_crush_range', value);


## The "sloshiness" of the image blending, normalized between 0.0 and 1.0.
## A value of 0.8 is very sloshy; a value of 0.2 is similar to old LCD screens.
var accumulative_blur: float:
  get():
    return material.get_shader_parameter('accumulative_blur__mix_ratio');
  set(value):
    return material.set_shader_parameter('accumulative_blur__mix_ratio', value);


# [TODO] Add controls for gradient_color_replace (give to camera view as well)
# [TODO] Add controls for color invert (give to camrea view as well)


func _ready() -> void:
  Events.previous_frame_captured.connect(_save_previous_rendered_frame);


func _save_previous_rendered_frame(texture: Texture2D, frame_delta: float) -> void:
  material.set_shader_parameter('accumulative_blur__last_frame', texture);
  material.set_shader_parameter('accumulative_blur__frame_delta', frame_delta);

  # Turn 'on' the accumulative blur after the first valid texture has been supplied.
  # [FIXME] This happens every frame, forever. Is there a performance cost for this?
  #     This pointless CPU to GPU communication.
  material.set_shader_parameter('accumulative_blur__sampler_is_valid', true);


## Over [param time] seconds, tweens all screen colors to their whitemost
## equivalents. Waits [param delay] seconds before tweening.
func white_out_async(time: float, delay: float = 0.0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_white_out_async(0.6, time);


## Over [param time] seconds, tweens all screen colors from white to their
## natural state. Waits [param delay] seconds before tweening.
func white_in_async(time: float, delay: float = 0.0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_white_out_async(0.0, time);


## Over [param time] seconds, tweens the whiteout shader parameter to the value
## [param to]. [param to] is a normalized value.
func _tween_white_out_async(to: float, time: float) -> void:
  var whiteout_tween := create_tween();
  whiteout_tween.set_trans(Tween.TRANS_SINE);
  whiteout_tween.set_ease(Tween.EASE_IN);
  whiteout_tween.tween_property(self, "white_cutoff_range", to, time);
  await whiteout_tween.finished;
