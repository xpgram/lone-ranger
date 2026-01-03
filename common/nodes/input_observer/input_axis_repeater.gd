## Uses timers to re-emit a vector input at set time intervals.
class_name InputAxisRepeater
extends Node


## Emitted when this monitor's input is ready to be handled.
signal input_triggered(vector: Vector2i);


## The context node for whether this branch of the scene tree has input focus.
@export var _focus_context: Control;

## Whether to limit inputs to just the up/down/left/right directions.
@export var orthogonal_only: bool = true;

## Whether changing the axes input direction without releasing it should also reset the
## interval timers.
@export var reset_time_on_direction_change: bool = true;

## Whether to emit the initial [signal input_triggered], when the repeater is first
## activated and before any time intervals have elapsed.
@export var emit_first_input_trigger: bool = true;

## The time in seconds between input pulses. Cannot be less than 0.
@export_custom(PROPERTY_HINT_NONE, 'suffix:s')
var interval_time: float = 0.25:
  set(time):
    interval_time = maxf(0, time);
    if _interval_timer:
      _interval_timer.wait_time = interval_time;

## The time in seconds between the first and the second input pulse.
## The "first" input pulse is sometimes ignored by [member emit_first_input_trigger], but
## always refers to the pulse on [code]time=0.0[/code]. [br]
##
## If this **value is negative**, it is assumed to be equal to [member interval_time].
@export_custom(PROPERTY_HINT_NONE, 'suffix:s')
var first_interval_time: float = -1.0:
  set(time):
    first_interval_time = time;
    if _first_pulse_timer:
      _first_pulse_timer.wait_time = _get_first_interval_time(first_interval_time, interval_time);


@export_group('Axis Actions')

@export var up_axis: StringName;

@export var down_axis: StringName;

@export var left_axis: StringName;

@export var right_axis: StringName;


## The instance for the [InputAxisRepeater]'s first pulse [Timer].
var _first_pulse_timer: Timer;

## The instance for the [InputAxisRepeater]'s repeat interval [Timer].
var _interval_timer: Timer;

## The input vector to repeat.
var _held_input_vector: Vector2;


func _ready() -> void:
  _check_focus_context_exists();
  _check_axes_exist();
  _instantiate_repeater_timers();
  _bind_signals();


func _unhandled_input(event: InputEvent) -> void:
  if (
      not _focus_context.has_focus()
      or not _event_is_axis_action(event)
  ):
    return;

  _focus_context.accept_event();

  var input_vector := Input.get_vector(left_axis, right_axis, up_axis, down_axis);

  if input_vector == Vector2.ZERO:
    _stop_timers();
    return;

  _held_input_vector = (
    _get_input_vector_from_event(event) if orthogonal_only
    else input_vector
  );

  _try_start_timers();


## Pushes an error if the [InputAxisRepeater] does not have a context node for assessing
## the user's input focus. Without input focus, the repeater assumes it is not appropriate
## to emit input triggers.
func _check_focus_context_exists() -> void:
  if not _focus_context:
    push_error('No user input focus exists for %s' % name);


## Pushes an error if the [InputAxisRepeater] references action names that do not exist in the
## [InputMap].
func _check_axes_exist() -> void:
  var axes := [
    up_axis,
    down_axis,
    left_axis,
    right_axis,
  ];

  for axis in axes:
    if not InputMap.has_action(axis):
      push_error("InputMap does not have an action called '%s'." % axis);


## Builds and adds to the scene tree the [InputAxisRepeater]'s pulse timers.
func _instantiate_repeater_timers() -> void:
  _interval_timer = Timer.new();
  _interval_timer.name = 'IntervalTimer';
  _interval_timer.one_shot = false;
  _interval_timer.autostart = false;
  _interval_timer.ignore_time_scale = true;
  _interval_timer.wait_time = interval_time;

  _first_pulse_timer = Timer.new();
  _first_pulse_timer.name = 'FirstIntervalTimer';
  _first_pulse_timer.one_shot = true;
  _first_pulse_timer.autostart = false;
  _first_pulse_timer.ignore_time_scale = true;
  _first_pulse_timer.wait_time = _get_first_interval_time(first_interval_time, interval_time);

  add_child(_interval_timer);
  add_child(_first_pulse_timer);


## Returns either [param time] if it is a suitable value for the first pulse interval,
## or [param default] if it is not.
func _get_first_interval_time(time: float, default: float) -> float:
  return time if time >= 0.0 else default;


## Attaches callbacks to signal events.
func _bind_signals() -> void:
  _focus_context.focus_exited.connect(_stop_timers);


## Returns true if [param event] is for an axis action.
func _event_is_axis_action(event: InputEvent) -> bool:
  var axes := [
    up_axis,
    down_axis,
    left_axis,
    right_axis,
  ];

  for axis in axes:
    if event.is_action(axis):
      return true;

  return false;


## Emits the second-by-count input trigger and starts the interval timer.
func _on_first_pulse_timer_timeout() -> void:
  input_triggered.emit(_held_input_vector);
  _interval_timer.start();


## Emits an input trigger.
func _on_interval_timer_timeout() -> void:
  input_triggered.emit(_held_input_vector);


## Returns a [Vector2] representing the most recent directional input. If [param event]
## is not a pressed event, returns the current [member _held_input_vector].
func _get_input_vector_from_event(event: InputEvent) -> Vector2:
  var new_input_vector = _held_input_vector;

  if event.is_action_pressed(up_axis):
    new_input_vector = Vector2i.UP;
  elif event.is_action_pressed(down_axis):
    new_input_vector = Vector2i.DOWN;
  elif event.is_action_pressed(left_axis):
    new_input_vector = Vector2i.LEFT;
  elif event.is_action_pressed(right_axis):
    new_input_vector = Vector2i.RIGHT;

  return new_input_vector;


## Starts the first pulse timer if neither timer is active, or if the current hold elapse
## time should not be preserved.
func _try_start_timers() -> void:
  if reset_time_on_direction_change:
    _stop_timers();

  if (
      _first_pulse_timer.is_stopped()
      and _interval_timer.is_stopped()
  ):
    _first_pulse_timer.start();

    if emit_first_input_trigger:
      input_triggered.emit(_held_input_vector);


## Stops all interval timers.
func _stop_timers() -> void:
  _first_pulse_timer.stop();
  _interval_timer.stop();
