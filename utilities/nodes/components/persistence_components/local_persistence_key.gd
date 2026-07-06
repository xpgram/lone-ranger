@tool
## A [Resource] to formalize the [PersistenceKey] management of a particular key
## local to a [PackedScene].
class_name LocalPersistenceKey
extends PersistenceKeyResource


## The name of this persistence key. It is ideal to name it something human
## readable and debuggable.
@export var persistence_key: StringName:
  set(value):
    persistence_key = value;
    resource_name = persistence_key;

## A unique-ish random identifier used to avoid naming conflicts between
## persistence keys. It is recommended you still try to name your keys
## intelligently, however. [br]
##
## In the rare case of a collision, this value may be edited in the .tscn or
## .tres this Resource is saved in.
@export var key_uid: StringName;


func _init() -> void:
  if not key_uid:
    key_uid = _generate_key_uid();


func _validate_property(property: Dictionary) -> void:
  if property.name == 'key_uid':
    property.usage |= PROPERTY_USAGE_READ_ONLY;


func _get_key() -> StringName:
  var key := key_uid;

  if persistence_key.length() > 0:
    key += ' %s' % persistence_key;

  return key;


## Returns a string with a unique-ish random set of characters.
func _generate_key_uid() -> StringName:
  return "Pkey_%s" % generate_scene_unique_id();
