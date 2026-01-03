##
class_name ScreenSpaceShader
extends ColorRect


const NULL_COLOR := Color8(1, 1, 1);


var _saved_gradient_start: Color;

var _saved_gradient_end: Color;

var _saved_pulse_color_gradient_start := Color.WHITE;

var _saved_pulse_color_gradient_end := Color.WHITE;


var pulse_progress: float:
  set(value):
    pulse_progress = value;

    var grad_start := lerp(_saved_gradient_start, _saved_pulse_color_gradient_start, pulse_progress) as Color;
    var grad_end := lerp(_saved_gradient_end, _saved_pulse_color_gradient_end, pulse_progress) as Color;

    _set_shader_param_gradient_start(grad_start);
    _set_shader_param_gradient_end(grad_end);


func _ready() -> void:
  _saved_gradient_start = material.get_shader_parameter('gradient_start') as Color;
  _saved_gradient_end = material.get_shader_parameter('gradient_end') as Color;


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


func pulse_color(screen_pulse_color: Color, screen_pulse_gradient_end := NULL_COLOR) -> void:
  _saved_pulse_color_gradient_start = screen_pulse_color;
  _saved_pulse_color_gradient_end = (
    screen_pulse_color if screen_pulse_gradient_end == NULL_COLOR
    else screen_pulse_gradient_end
  );

  var tween := create_tween();
  tween.tween_property(self, 'pulse_progress', 1.0, 0.1);
  await tween.finished;

  await get_tree().create_timer(0.3).timeout;

  tween = create_tween();
  tween.tween_property(self, 'pulse_progress', 0.0, 0.5);
  await tween.finished;
