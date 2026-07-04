##
@abstract class_name PersistenceKeyComponent
extends Component


## Returns the dictionary key for this persistence value.
@abstract func _get_key() -> StringName;


## Sets the value of the persistence key to [param value].
func write(value: Variant) -> void:
  # [FIXME] value is a bool?
  PersistenceKey.set_bool(_get_key(), value);


## Returns the value held under the persistence key. [br]
##
## Override this function to specify the return type.
func read() -> Variant:
  return PersistenceKey.get_bool(_get_key());
