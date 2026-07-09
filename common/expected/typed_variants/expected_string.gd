## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them.
class_name ExpectedString
extends Expected


func get_value() -> String:
  return super.get_value();
