##
class_name ScreenSpaceShader
extends ColorRect


var _saved_gradient_start: Color;

var _saved_gradient_end: Color;

var _saved_pulse_color := Color.WHITE;


var pulse_progress: float:
  set(value):
    pulse_progress = value;

    var grad_start := lerp(_saved_gradient_start, _saved_pulse_color, pulse_progress) as Color;
    var grad_end := lerp(_saved_gradient_end, _saved_pulse_color, pulse_progress) as Color;

    _set_shader_param_gradient_start(grad_start);
    _set_shader_param_gradient_end(grad_end);


func _ready() -> void:
  set_color_gradient_start(Color.from_hsv(180 / 360.0, 0.5, 1.0));
  set_color_gradient_end(Color.from_hsv(120 / 360.0, 0.5, 1.0));


func set_color_gradient_start(start_color: Color) -> void:
  _saved_gradient_start = start_color;
  _set_shader_param_gradient_start(_saved_gradient_start);


func set_color_gradient_end(end_color: Color) -> void:
  _saved_gradient_end = end_color;
  _set_shader_param_gradient_end(_saved_gradient_end);


func _set_shader_param_gradient_start(start_color: Color) -> void:
  if not material:
    return;

  material.set_shader_parameter('gradient_start', start_color);


func _set_shader_param_gradient_end(end_color: Color) -> void:
  if not material:
    return;

  material.set_shader_parameter('gradient_end', end_color);


func pulse_color(screen_pulse_color: Color) -> void:
  _saved_pulse_color = screen_pulse_color;

  var tween := create_tween();
  tween.tween_property(self, 'pulse_progress', 1.0, 0.1);
  await tween.finished;

  await get_tree().create_timer(0.3).timeout;

  tween = create_tween();
  tween.tween_property(self, 'pulse_progress', 0.0, 0.5);
  await tween.finished;
