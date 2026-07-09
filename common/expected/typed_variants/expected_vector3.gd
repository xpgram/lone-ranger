## A alternative error handling method that puts exceptions into the return
## type, encouraging developers to deal with them.
class_name ExpectedVector3
extends Expected


func get_value() -> Vector3:
  return super.get_value();
