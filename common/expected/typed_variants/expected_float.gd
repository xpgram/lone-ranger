## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them.
class_name ExpectedFloat
extends Expected


func get_value() -> float:
  return super.get_value();
