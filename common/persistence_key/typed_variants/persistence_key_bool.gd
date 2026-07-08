@tool
## A boolean-type [PersistenceKey], an interface for a key-value in the global
## [PersistenceDictionary].
class_name PersistenceKeyBool
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_BOOL;


func write(value: bool) -> void:
  super.write(value);


func read() -> bool:
  return super.read();
