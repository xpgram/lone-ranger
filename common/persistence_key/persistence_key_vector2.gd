@tool
## A Vector2-type [PersistenceKey].
class_name PersistenceKeyVector2
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_VECTOR2;


## Returns the Vector2 value of this persistence key.
func read() -> Vector2:
  return super.read();
