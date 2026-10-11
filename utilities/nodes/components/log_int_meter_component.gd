## @tool [br]
##
## [TODO] Rewrite this
##
## An [IntMeterComponent] that treats its value meter as if it were the product of
## a different meter whose euclidean space has been curved by a quadratic function. [br]
##
## The effect is such that values in normal euclidean space sum together in larger
## amounts when the meter is low, and smaller amounts when the meter is high. [br]
##
## Some examples At a [member _curve_weight] of 4.0, and a maximum of 1000:
## - 250 + 250 => 650
@tool
class_name LogIntMeterComponent
extends IntMeterComponent


## The exponential power of the quadratic that translates the raw euclidean space
## to the meter's actual space.
@export var _curve_weight := 4.0;


## Returns the "real" proportion-filled of this meter [i]before[/i] the
## space-curving function is applied.
func get_raw_proportion() -> float:
  return _unwarp(proportion_filled());


## Sets the meter's proportion filled in "real" space, [i]before[/i] the
## space-curving function is applied.
func set_by_raw_proportion(raw_normal: float) -> void:
  var normal := _warp(clampf(raw_normal, 0, 1));
  set_by_proportion(normal);


## Returns the "real" value of this meter as [i]before[/i] the space-curving
## function is applied.
func get_raw_value() -> int:
  var raw_normal := get_raw_proportion();
  return get_value_from_proportion(raw_normal);


## Sets the meter's value in "real" space, [i]before[/i] the space-curving
## function is applied.
func set_by_raw_value(raw_value: int) -> void:
  var raw_normal := proportion_from(raw_value);
  var normal := _warp(raw_normal);
  value = get_value_from_proportion(normal);


## Add a proportion to the meter in "real" space, [i]before[/i] the
## space-curving function is applied.
func add_raw_proportion(raw_normal: float) -> void:
  set_by_raw_proportion(get_raw_proportion() + raw_normal);


## Add a value to the meter in "real" space, [i]before[/i] the space-curving
## function is applied.
func add_raw_value(raw_value: int) -> void:
  set_by_raw_value(get_raw_value() + raw_value);


## Converts a given [param raw_normal] between 0.0 and 1.0 from "real" space to
## "actual" space. [br]
##
## Real space is as before the space-curving function is applied. Actual is after.
func _warp(raw_normal: float) -> float:
  return 1 - abs((1 - raw_normal)**(_curve_weight));


## Converts a given [param normal] between 0.0 and 1.0 from "actual" space to
## "real" space. [br]
##
## Actual space is as after the space-curving function is applied. Real is before.
func _unwarp(normal: float) -> float:
  return 1 - (1 - normal)**(1 / _curve_weight);
