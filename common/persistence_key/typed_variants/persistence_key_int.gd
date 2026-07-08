## @tool [br]
## An integer-type [PersistenceKey], an interface for a key-value in the global
## [PersistenceDictionary].
@tool
class_name PersistenceKeyInt
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_INT;


func write(value: int) -> void:
  super.write(value);


func read() -> int:
  return super.read();
