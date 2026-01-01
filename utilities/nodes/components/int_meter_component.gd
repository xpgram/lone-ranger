## Maintains a clamped int value and emits signals as it changes.
@tool
@abstract class_name IntMeterComponent
extends BaseComponent


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


@export_group('Int Meter')

## Whether the meter should emit its event signals in the engine editor context.
@export var _emit_signals_in_editor := false;

## The minimum limit for the meter.
@export var minimum: int = 0:
  set(number):
    var old_minimum := minimum;
    minimum = number;

    if minimum > maximum:
      maximum = minimum;
    if minimum > value:
      value = minimum;

    if _can_emit_signals() and old_minimum != minimum:
      minimum_changed.emit(minimum, old_minimum);

## The maximum limit for the meter.
@export var maximum: int = 1:
  set(number):
    var old_maximum := maximum;
    maximum = number;

    if maximum < minimum:
      minimum = maximum;
    if maximum < value:
      value = maximum;

    if _can_emit_signals() and old_maximum != maximum:
      maximum_changed.emit(maximum, old_maximum);

## The current int value of the meter.
@export var value: int = 1:
  set(number):
    var old_value := value;
    value = clampi(number, minimum, maximum);

    if _can_emit_signals() and old_value != value:
      value_changed.emit(value, old_value);

      if value == minimum:
        empty.emit();
      elif value == maximum:
        full.emit();

## Sets the meter's value to its maximum.
@export_tool_button('Set Full') var tool_button_set_hp_to_full = set_hp_to_full;


## Sets the meter's value to its maximum.
func set_hp_to_full() -> void:
  value = maximum;
  # TODO Add undo/redo?


## Returns true if the meter is allowed to emit value-changed event signals.
func _can_emit_signals() -> bool:
  return not Engine.is_editor_hint() or _emit_signals_in_editor;
