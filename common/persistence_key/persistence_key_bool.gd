@tool
##
class_name PersistenceKeyBool
extends PersistenceKey


func _deserialize_ready() -> void:
  super._deserialize_ready();

  if _initial_value == null:
    _initial_value = false;


func _validate_property(property: Dictionary) -> void:
  super._validate_property(property);

  if property.name == '_initial_value':
    property.type = TYPE_BOOL;


func _property_can_revert(property: StringName) -> bool:
  if property == '_initial_value':
    return true;

  return false;


func _property_get_revert(property: StringName) -> Variant:
  if property == '_initial_value':
    return false;

  return null;


## Returns the boolean value of this persistence key.
func read() -> bool:
  return super.read();
