@tool
## A Quaternion-type [PersistenceKey].
class_name PersistenceKeyQuaternion
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_QUATERNION;


## Returns the Quaternion value of this persistence key.
func read() -> Quaternion:
  return super.read();
