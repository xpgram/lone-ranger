## Maintains a clamped int value and emits signals as it changes.
class_name IntMeter
extends Node


## Emitted whenever the meter is set to its maximum value from some value that is not its
## maximum.
signal full();

## Emitted whenever the meter is set to its minimum value from some value that is not its
## minimum.
signal empty();

## Emitted whenever the meter's [member value] is set to a new value. Is **not** emitted
## when [member value] is set to the same value.
signal value_changed(value: int);


## The minimum limit for the meter.
@export var minimum: int = 0;

## The maximum limit for the meter.
@export var maximum: int = 1;

## The current int value of the meter.
@export var value: int = maximum:
  get():
    return value;
  set(number):
    var old_value := value;
    value = clampi(number, minimum, maximum);

    if old_value != value:
      value_changed.emit(value);

      if value == minimum:
        empty.emit();
      elif value == maximum:
        full.emit();
