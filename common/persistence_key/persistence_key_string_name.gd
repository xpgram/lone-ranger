@tool
## A string-name-type [PersistenceKey].
class_name PersistenceKeyStringName
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_STRING_NAME;


## Returns the StringName value of this persistence key.
func read() -> StringName:
  return super.read();
