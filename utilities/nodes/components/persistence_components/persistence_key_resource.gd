## An object to wrap a [StringName] key to a [PersistenceKey] value. [br]
##
## This object exists to help officialize the otherwise arbitrary string value
## used to access this value normally by taking advantage of Godot's [Resource]
## and UID systems. [br]
##
## By giving two objects a persistence_key field, and assigning both to the same
## Resource UID, they are able to share the persistence key without having to
## maintain strictly-matching string values, and it becomes possible to update
## said string value to all observers at once.
@abstract class_name PersistenceKeyResource
extends Resource


## The value type of this persistence key. [br]
##
## If set to [TYPE_NIL], then all types will be considered valid.
@export var _value_type: Variant.Type:
  set(value):
    _value_type = value;
    notify_property_list_changed();

## The default value of this persistence key.
@export var _initial_value: Variant;


@export var test: String = '':
  set(value):
    test = value;
    print('initial value == ', _initial_value);


## Returns the dictionary key for this persistence value.
@abstract func _get_key() -> StringName;


func _validate_property(property: Dictionary) -> void:
  if property.name == '_initial_value':

    if property.type != _value_type:
      property.type = _value_type;
      if _value_type == TYPE_NIL:
        property.erase('type');
      # Set the default value for the new type.
      _initial_value = type_convert(null, _value_type);


# [TODO] What if, instead of setting the type and then the value,
#   we set the value and infer the type in a readonly?


func _property_can_revert(property: StringName) -> bool:
  if property == &'_initial_value':
    return _initial_value != type_convert(null, _value_type);

  return false;


func _property_get_revert(property: StringName) -> Variant:
  if property == &'_initial_value':
    return type_convert(null, _value_type);

  return null;


## Sets the value of the persistence key to [param value].
func write(value: Variant) -> void:
  assert(_value_type_valid(value),
    "Cannot assign value of type %s to persistence key of type %s." % [typeof(value), _value_type]);
  PersistenceKey.write(_get_key(), value);


## Returns the value of this persistence key.
func read() -> Variant:
  return PersistenceKey.read(_get_key(), _initial_value);


## Returns true if [param value] is of the same assigned [Variant.Type] as this
## persistence value.
func _value_type_valid(value: Variant) -> bool:
  return (
    typeof(value) == _value_type
    or typeof(value) == TYPE_NIL
  );
