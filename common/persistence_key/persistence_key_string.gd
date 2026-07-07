@tool
## A string-type [PersistenceKey].
class_name PersistenceKeyString
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_STRING;


## Returns the String value of this persistence key.
func read() -> String:
  return super.read();
