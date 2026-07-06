## A [Resource] to formalize the [PersistenceKey] management of a particular
## global key.
class_name GlobalPersistenceKey
extends PersistenceKeyResource


# [TASK] Global has no UID prefix: is this actually valuable?


##
@export var persistence_key: StringName;


func _get_key() -> StringName:
  return persistence_key;
