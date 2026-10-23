## An object interface for the UI-space shader applied to the player's HUD view.
class_name PlayerHUDShader
extends CanvasGroup


## The brightness value adjustment. A value of 1.0 is neutral.
var brightness: float = 1.0:
  get():
    return material.get_shader_parameter('adjust_brightness__coefficient');
  set(value):
    material.set_shader_parameter('adjust_brightness__coefficient', value);


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
