class_name IntMeter
extends Node


signal full();
signal empty();


@export var minimum: int = 0;

@export var maximum: int = 1;

@export var value: int = maximum:
  get():
    return value;
  set(number):
    value = clampi(number, minimum, maximum);

    if value == minimum:
      empty.emit();
    elif value == maximum:
      full.emit();



