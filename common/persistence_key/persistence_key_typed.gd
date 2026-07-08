## @tool [br]
## A template for typed variants of [PersistenceKey].
@tool
@abstract class_name PersistenceKeyTyped
extends PersistenceKey


## Returns the [Variant.Type] that this [PersistenceKey] is restricted to.
@abstract func _get_value_type() -> Variant.Type;


func _deserialize_ready() -> void:
  super._deserialize_ready();

  if _initial_value == null:
    _initial_value = _get_initial_value_default();


func _validate_property(property: Dictionary) -> void:
  super._validate_property(property);

  if property.name == '_initial_value':
    property.type = _get_value_type();


func _property_can_revert(property: StringName) -> bool:
  if property == '_initial_value':
    return true;

  return false;


func _property_get_revert(property: StringName) -> Variant:
  if property == '_initial_value':
    return _get_initial_value_default();

  return null;


## Returns the default value for the [Variant.Type] of this key.
func _get_initial_value_default() -> Variant:
  return type_convert(null, _get_value_type());
