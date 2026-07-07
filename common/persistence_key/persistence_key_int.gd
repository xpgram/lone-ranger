@tool
## An integer-type [PersistenceKey].
class_name PersistenceKeyInt
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_INT;


## Returns the int value of this persistence key.
func read() -> int:
  return super.read();
