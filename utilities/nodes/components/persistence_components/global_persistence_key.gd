## 
class_name GlobalPersistenceKey
extends PersistenceKeyComponent


##
@export var persistence_key: StringName;


func _get_key() -> StringName:
  return persistence_key;
