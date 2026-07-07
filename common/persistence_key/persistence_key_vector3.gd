@tool
## A Vector3-type [PersistenceKey].
class_name PersistenceKeyVector3
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_VECTOR3;


## Returns the Vector3 value of this persistence key.
func read() -> Vector3:
  return super.read();
