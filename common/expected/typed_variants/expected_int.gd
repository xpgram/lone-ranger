## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them.
class_name ExpectedInt
extends Expected


func get_value() -> int:
  return super.get_value();
