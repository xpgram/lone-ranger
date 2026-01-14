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


func set_fade_in(value: float) -> void:
  # This should limit the value to increments of 0.25.
  value = round(value * 4) / 4.0;

  value = clampf(value, 0.0, 1.0);
  material.set_shader_parameter('fade_in_progress', value);


func set_silhoette_threshhold(value: float) -> void:
  # This should limit the value to increments of 0.25.
  value = round(value * 4) / 4.0;

  value = clampf(value, 0.0, 1.0);
  material.set_shader_parameter('silhoette_threshhold', value);


# FIXME Remove these debug controls.
func _unhandled_input(_event: InputEvent) -> void:
  # FIXME These are being called like 16,000 times a second now. Wtf?
  #   I've determined that was my PS5 controller somehow. Was it doing that before?
  #   That's really weird.

  # Adjust fade-in.
  if Input.is_key_pressed(KEY_U):
    var progress: float = material.get_shader_parameter('fade_in_progress');
    progress = clampf(progress + 0.25, 0.0, 1.0);
    material.set_shader_parameter('fade_in_progress', progress);
  elif Input.is_key_pressed(KEY_J):
    var progress: float = material.get_shader_parameter('fade_in_progress');
    progress = clampf(progress - 0.25, 0.0, 1.0);
    material.set_shader_parameter('fade_in_progress', progress);

  # Adjust silhoette.
  if Input.is_key_pressed(KEY_K):
    var threshhold: float = material.get_shader_parameter('silhoette_threshhold');
    threshhold = clampf(threshhold + 0.25, 0.0, 1.0);
    material.set_shader_parameter('silhoette_threshhold', threshhold);
  elif Input.is_key_pressed(KEY_I):
    var threshhold: float = material.get_shader_parameter('silhoette_threshhold');
    threshhold = clampf(threshhold - 0.25, 0.0, 1.0);
    material.set_shader_parameter('silhoette_threshhold', threshhold);

  # Toggle gradient.
  if Input.is_key_pressed(KEY_O):
    set_color_gradient_start(Color.WHITE);
    set_color_gradient_end(Color.WHITE);
  elif Input.is_key_pressed(KEY_L):
    set_color_gradient_start(Color.from_hsv(200 / 360.0, 1.0, 1.0));
    set_color_gradient_end(Color.from_hsv(160 / 360.0, 1.0, 1.0));

  # Toggle color invert.
  if Input.is_key_pressed(KEY_P):
    material.set_shader_parameter('invert_colors', true);
  elif Input.is_key_pressed(KEY_SEMICOLON):
    material.set_shader_parameter('invert_colors', false);
