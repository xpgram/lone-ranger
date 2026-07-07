@tool
## A float-type [PersistenceKey].
class_name PersistenceKeyFloat
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_FLOAT;


## Returns the float value of this persistence key.
func read() -> float:
  return super.read();
