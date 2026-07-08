## @tool [br]
## A String-type [PersistenceKey], an interface for a key-value in the global
## [PersistenceDictionary].
@tool
class_name PersistenceKeyString
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_STRING;


func write(value: String) -> void:
  super.write(value);


func read() -> String:
  return super.read();
