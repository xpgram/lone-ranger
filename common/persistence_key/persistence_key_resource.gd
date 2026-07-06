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


## The default value of this persistence key.
@export var _initial_value: Variant;


## Returns the dictionary key for this persistence value.
@abstract func _get_key() -> StringName;


func _validate_property(property: Dictionary) -> void:
  if property.name == '_initial_value':
    property.type = TYPE_NIL;


## Sets the value of the persistence key to [param value].
func write(value: Variant) -> void:
  assert(_value_type_valid(value),
    "Cannot assign value of type %s to persistence key of type %s." % [typeof(value), _get_value_type()]);
  PersistenceDictionary.write(_get_key(), value);


## Returns the value of this persistence key.
func read() -> Variant:
  return PersistenceDictionary.read(_get_key(), _initial_value);


## Erases this persistence value from the global dictionary. Returns true if a
## value existed, otherwise false.
func erase() -> bool:
  return PersistenceDictionary.erase(_get_key());


## Returns true if [param value] is of the same assigned [Variant.Type] as this
## persistence value.
func _value_type_valid(value: Variant) -> bool:
  var preferred_type := _get_value_type();
  return (
    typeof(value) == preferred_type
    or preferred_type == TYPE_NIL
  );


## Returns the value type of this persistence key.
func _get_value_type() -> Variant.Type:
  return typeof(_initial_value) as Variant.Type;
