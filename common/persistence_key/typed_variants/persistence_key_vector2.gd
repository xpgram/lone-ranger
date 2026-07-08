## @tool [br]
## A Vector2-type [PersistenceKey], an interface for a key-value in the global
## [PersistenceDictionary].
@tool
class_name PersistenceKeyVector2
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_VECTOR2;


func write(value: Vector2) -> void:
  super.write(value);


func read() -> Vector2:
  return super.read();
