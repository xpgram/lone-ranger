## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them.
class_name ExpectedStringName
extends Expected


func get_value() -> StringName:
  return super.get_value();
