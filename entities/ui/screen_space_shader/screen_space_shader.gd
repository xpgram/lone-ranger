## An object interface for the screen-space shader applied to the player's camera view.
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


func _process(_delta: float) -> void:
  var camera := get_parent() as Camera2D;
  # var mantissa := camera.global_position - Vector2(Vector2i(camera.global_position));
  # material.set_shader_parameter('pixelizer_subpixel_offset', mantissa);

  material.set_shader_parameter('pixelate_rotation_deg', camera.rotation_degrees);


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


## Tweens the fade_in property from [param from] to [param to] over [param time] seconds.
func _tween_fade_in_async(from: float, to: float, time: float) -> void:
  var fade_tween := create_tween();
  fade_tween.set_trans(Tween.TRANS_SINE);
  fade_tween.set_ease(Tween.EASE_IN);
  fade_tween.tween_method(set_fade_in, from, to, time);
  await fade_tween.finished;


## Tweens the fade_in property from 1 to 0.
func fade_out_async(time: float, delay: float) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_fade_in_async(1.0, 0.0, time);


## Tweens the fade_in property from 0 to 1.
func fade_in_async(time: float, delay: float = 0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_fade_in_async(0.0, 1.0, time);


func get_fade_in() -> float:
  return material.get_shader_parameter('fade_in_progress');


func set_fade_in(value: float) -> void:
  # This should limit the value to increments of 0.25.
  value = ceil(value * 5 - 1) / 4.0;

  value = clampf(value, 0.0, 1.0);
  material.set_shader_parameter('fade_in_progress', value);


func get_silhoette_threshhold() -> float:
  return material.get_shader_parameter('silhoette_threshhold');


func set_silhoette_threshhold(value: float) -> void:
  # [FIXME] This formula, ceil(5v-1) / 4, there's some inconsistency in how it's applied.
  #   I don't get it, but the shader doesn't like it for the silhoette values.
  # value = ceil(value * 5 - 1) / 4.0;
  value = clampf(value, 0.0, 1.0);
  material.set_shader_parameter('silhoette_threshhold', value);


## Tweens the whiteout property from [param from] to [param to] over [param time] seconds.
func _tween_whiteout_async(from: float, to: float, time: float) -> void:
  var tween := create_tween();
  tween.tween_method(set_silhoette_white_threshhold, from, to, time);
  await tween.finished;


## Tweens the white_silhoette property from none to whited-out.
func white_out_async(time: float, delay: float = 0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_whiteout_async(1.0, 0.4, time);


## Tweens the white_silhoette property from whited-out to none.
func white_in_async(time: float, delay: float = 0) -> void:
  await get_tree().create_timer(delay).timeout;
  await _tween_whiteout_async(0.4, 1.0, time);


func set_silhoette_white_threshhold(value: float) -> void:
  value = clampf(value, 0.0, 1.0);
  material.set_shader_parameter('silhoette_white_threshhold', value);


# [FIXME] Remove these debug controls.
func _unhandled_input(event: InputEvent) -> void:
  if event is not InputEventKey or not event.pressed:
    return;

  # Adjust fade-in.
  if event.keycode == KEY_Y:
    set_fade_in(get_fade_in() + 0.25);
    accept_event();
  elif event.keycode == KEY_H:
    set_fade_in(get_fade_in() - 0.25);
    accept_event();

  # Adjust silhoette.
  if event.keycode == KEY_J:
    set_silhoette_threshhold(get_silhoette_threshhold() + 0.25);
    accept_event();
  elif event.keycode == KEY_U:
    set_silhoette_threshhold(get_silhoette_threshhold() - 0.25);
    accept_event();

  # Adjust white-silhoette
  if event.keycode == KEY_I:
    var threshhold: float = material.get_shader_parameter('silhoette_white_threshhold');
    set_silhoette_white_threshhold(threshhold + 0.25);
    accept_event();
  elif event.keycode == KEY_K:
    var threshhold: float = material.get_shader_parameter('silhoette_white_threshhold');
    set_silhoette_white_threshhold(threshhold - 0.25);
    accept_event();

  # Toggle gradient.
  if event.keycode == KEY_O:
    set_color_gradient_start(Color.WHITE);
    set_color_gradient_end(Color.WHITE);
    accept_event();
  elif event.keycode == KEY_L:
    set_color_gradient_start(Color.from_hsv(200 / 360.0, 1.0, 1.0));
    set_color_gradient_end(Color.from_hsv(160 / 360.0, 1.0, 1.0));
    accept_event();

  # Toggle color invert.
  if event.keycode == KEY_P:
    material.set_shader_parameter('invert_colors', false);
    accept_event();
  elif event.keycode == KEY_SEMICOLON:
    material.set_shader_parameter('invert_colors', true);
    accept_event();

  # Do a color pulse.
  if event.keycode == KEY_COMMA:
    pulse_color(
      Color.from_hsv( 0 / 360.0, 0.80, 1.00),
      # Color.from_hsv( 15 / 360.0, 0.80, 1.00),
    );
    accept_event();
  if event.keycode == KEY_PERIOD:
    pulse_color(Color.PURPLE, Color.MAROON);
    accept_event();
