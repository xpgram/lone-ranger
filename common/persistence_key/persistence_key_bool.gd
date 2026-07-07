@tool
## A boolean-type [PersistenceKey].
class_name PersistenceKeyBool
extends PersistenceKeyTyped

# [TODO] Write a better doc string for PersistenceKey, borrow it here.


func _get_value_type() -> Variant.Type:
  return TYPE_BOOL;


## Returns the boolean value of this persistence key.
func read() -> bool:
  return super.read();
