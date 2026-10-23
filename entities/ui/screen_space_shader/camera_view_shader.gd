## An object interface for the screen-space shader applied to the player's camera view.
class_name PlayerCameraViewShader
extends ColorRect


## The target resolution of the pixelated image.
var pixelate_resolution: Vector2i:
  get():
    return material.get_shader_parameter('pixelate__resolution');
  set(value):
    material.set_shader_parameter('pixelate__resolution', value);


## The brightness value adjustment. A value of 1.0 is neutral.
var brightness: float = 1.0:
  get():
    return material.get_shader_parameter('adjust_brightness__coefficient');
  set(value):
    material.set_shader_parameter('adjust_brightness__coefficient', value);


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


func _ready() -> void:
  Events.player_camera_position_changed.connect(_on_player_camera_position_changed);
  Events.player_camera_rotation_changed.connect(_on_player_camera_rotation_changed);


## Updates shader paramters when the player camera's position changes.
func _on_player_camera_position_changed(camera_position: Vector2) -> void:
  material.set_shader_parameter('pixelate__offset', camera_position);


## Updates shader parameters when the player camera's rotation changes.
func _on_player_camera_rotation_changed(camera_rotation: float) -> void:
  material.set_shader_parameter('pixelate__rotation', camera_rotation);


## Over [param time] seconds, tweens all screen colors to their blackmost
## equivalents. Waits [param delay] seconds before tweening.
func fade_out_async(time: float, delay: float = 0.0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_fade_in_async(0.0, time);


## Over [param time] seconds, tweens all screen colors from black to their
## natural state. Waits [param delay] seconds before tweening.
func fade_in_async(time: float, delay: float = 0.0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_fade_in_async(1.0, time);


## Tweens the fade_in property to [param to] over [param time] seconds.
func _tween_fade_in_async(to: float, time: float) -> void:
  var fade_tween := create_tween();
  fade_tween.set_trans(Tween.TRANS_SINE);
  fade_tween.set_ease(Tween.EASE_IN);
  fade_tween.tween_property(self, 'brightness', to, time);
  await fade_tween.finished;
