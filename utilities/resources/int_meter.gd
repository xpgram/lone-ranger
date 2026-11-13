## @tool [br]
## Maintains a clamped int value and emits signals as it changes.
@tool
class_name IntMeter
extends Resource


# [FIXME] How do I bridge the overlap between IntMeter and IntMeterComponent?


## Emitted whenever the meter is set to its maximum value from some value that is not its
## maximum.
signal full();

## Emitted whenever the meter is set to its minimum value from some value that is not its
## minimum.
signal empty();

## Emitted whenever the meter's [member value] is set to a new value. Is **not** emitted
## when [member value] is set to the same value.
signal value_changed(value: int, old_value: int);

## Emitted whenever the meter's [member minimum] is set to a new value. It **not** emitted
## when [member minimum] is set to the same value.
signal minimum_changed(minimum: int, old_minimum: int);

## Emitted whenever the meter's [member maximum] is set to a new value. It **not**
## emitted when [member maximum] is set to the same value.
signal maximum_changed(maximum: int, old_maximum: int);


## The minimum limit for the meter value.
@export var minimum := 0:
  set(number):
    var old_minimum := minimum;
    minimum = mini(number, maximum);

    if _can_emit_signals() and old_minimum != minimum:
      minimum_changed.emit(minimum, old_minimum);

    if not _setters_lock.thread_locked():
      value = clampi(value, minimum, maximum);
      _setters_lock.unlock();


## The maximum limit for the meter value.
@export var maximum := 10:
  set(number):
    var old_maximum := maximum;
    maximum = maxi(number, minimum);

    if _can_emit_signals() and old_maximum != maximum:
      maximum_changed.emit(maximum, old_maximum);

    if not _setters_lock.thread_locked():
      value = clampi(value, minimum, maximum);
      _setters_lock.unlock();


## The current int value of the meter.
@export var value := 0:
  set(number):
    var old_value = value;
    value = clampi(value, minimum, maximum);

    if _can_emit_signals() and old_value != value:
      value_changed.emit(value, old_value);
      if value == minimum:
        empty.emit();
      elif value == maximum:
        full.emit();


## Whether the meter should emit its event signals in the engine editor context.
@export var _emit_signals_in_editor := false;

## Sets the meter's value to its maximum.
@warning_ignore("unused_private_class_variable")
@export_tool_button('Set Full') var _tool_button_set_hp_to_full = set_hp_to_full;


## A lock to prevent infinite recursion when properties set other properties in
## their setters.
var _setters_lock := Padlock.new();


@warning_ignore("shadowed_variable")
func _init(minimum := 0, maximum := 10, value := 0) -> void:
  self.minimum = minimum;
  self.maximum = maximum;
  self.value = value;


## Returns the value range between [member minimum] and [member maximum].
func get_value_range() -> int:
  return maximum - minimum;


## Returns the [param normal] as a value of the meter, rounded to the nearest int.
func get_value_from_proportion(normal: float) -> int:
  var raw_value := roundi(normal * get_value_range() + minimum);
  return clampi(raw_value, minimum, maximum);


## Returns the proportion of the meter filled as a number between 0.0 and 1.0.
func proportion_filled() -> float:
  return proportion_from(value);


## Returns [param number] as a proportion of the meter: a number between 0.0 and 1.0.
func proportion_from(number: int) -> float:
  var normal := float(number - minimum) / get_value_range();
  return clampf(normal, 0.0, 1.0);


## Sets the meter's [member value] to a proportion of the total range.
func set_by_proportion(normal: float) -> void:
  value = roundi(normal * get_value_range() + minimum);


## Sets the meter's value to its maximum.
func set_hp_to_full() -> void:
  value = maximum;


## Returns true if the meter is allowed to emit value-changed event signals.
func _can_emit_signals() -> bool:
  return not Engine.is_editor_hint() or _emit_signals_in_editor;
