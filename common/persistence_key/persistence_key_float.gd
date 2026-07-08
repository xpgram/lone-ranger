@tool
## A float-type [PersistenceKey], an interface for a key-value in the global
## [PersistenceDictionary].
class_name PersistenceKeyFloat
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_FLOAT;


func write(value: float) -> void:
  super.write(value);


func read() -> float:
  return super.read();
