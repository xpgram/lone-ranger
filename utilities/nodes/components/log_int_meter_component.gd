## @tool [br]
##
## An [IntMeterComponent] that treats its value meter as if it were the product of
## a linear meter and a space-curving function. [br]
##
## Any operations in unwarped space are converted from warped space, performed,
## then converted back. This means the meter can be used as normal, but certain
## operations may be attenuated by performing them "before" (in effect) the
## space-curving function has been applied. [br]
##
## Some examples of adding by unwarped values at a [member _curve_weight] of 4.0,
## and a [member maximum] of 1000: [br]
##
## [codeblock]
##  Value 250 + 250 => 786 (+536)
##  Value 500 + 250 => 878 (+378)
##  Value 750 + 250 => 956 (+206)
## [/codeblock]
##
## As shown, the value in warped space that +250 in unwarped space sums to can
## represent much larger gains depending on the meter's starting [member value].
@tool
class_name LogIntMeterComponent
extends IntMeterComponent


## The exponential power of the quadratic that translates the raw euclidean space
## to the meter's actual space.
@export var _curve_weight := 4.0;


## Returns the proportion of the meter filled in unwarped space as a number
## between 0.0 and 1.0.
func unwarped_proportion_filled() -> float:
  return _unwarp(proportion_filled());


## Sets the meter's proportion filled in unwarped space. The resulting
## [member value] will be in warped space.
func set_by_unwarped_proportion(normal: float) -> void:
  var warped_normal := _warp(clampf(normal, 0, 1));
  set_by_proportion(warped_normal);


## Returns the value of the meter in unwarped space.
func unwarped_value() -> int:
  var raw_normal := unwarped_proportion_filled();
  return get_value_from_proportion(raw_normal);


## Sets the meter's value in unwarped space. The resulting [member value] will
## be in warped space.
func set_by_unwarped_value(number: int) -> void:
  var raw_normal := proportion_from(number);
  var normal := _warp(raw_normal);
  value = get_value_from_proportion(normal);


## Add a proportion to the meter in unwarped space. The resulting [member value]
## wil be in warped space.
func add_unwarped_proportion(normal: float) -> void:
  set_by_unwarped_proportion(unwarped_proportion_filled() + normal);


## Add a value to the meter in unwarped space. The resulting [member value] will
## be in warped space.
func add_unwarped_value(number: int) -> void:
  set_by_unwarped_value(unwarped_value() + number);


## Converts a given [param unwarped_normal] between 0.0 and 1.0 to warped space. [br]
##
## Warped space is the euclidean space after the curving function has been applied.
func _warp(normal: float) -> float:
  return 1 - abs((1 - normal)**(_curve_weight));


## Converts a given [param warped_normal] between 0.0 and 1.0 to unwarped space.
##
## Warped space is the euclidean space after the curving function has been applied.
func _unwarp(normal: float) -> float:
  return 1 - (1 - normal)**(1 / _curve_weight);
