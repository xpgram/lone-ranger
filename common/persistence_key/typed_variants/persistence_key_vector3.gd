## @tool [br]
## A Vector3-type [PersistenceKey], an interface for a key-value in the global
## [PersistenceDictionary].
@tool
class_name PersistenceKeyVector3
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_VECTOR3;


func write(value: Vector3) -> void:
  super.write(value);


func read() -> Vector3:
  return super.read();
