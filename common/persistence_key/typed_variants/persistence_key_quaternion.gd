@tool
## A Quaternion-type [PersistenceKey], an interface for a key-value in the
## global [PersistenceDictionary].
class_name PersistenceKeyQuaternion
extends PersistenceKeyTyped


func _get_value_type() -> Variant.Type:
  return TYPE_QUATERNION;


func write(value: Quaternion) -> void:
  super.write(value);


func read() -> Quaternion:
  return super.read();
