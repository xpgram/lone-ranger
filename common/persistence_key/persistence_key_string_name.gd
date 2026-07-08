@tool
## A StringName-type [PersistenceKey], an interface for a key-value in the
## global [PersistenceDictionary].
class_name PersistenceKeyStringName
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_STRING_NAME;


func write(value: StringName) -> void:
  super.write(value);


func read() -> StringName:
  return super.read();
