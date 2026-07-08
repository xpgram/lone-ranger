@tool
## A [Resource] to formalize the [PersistenceKey] management of a particular key
## local to a [PackedScene].
##
## [b]Note:[/b] This type requires that [PersistenceDictionary] is a global
## autoload to function.
class_name PersistenceKey
extends PersistenceKeyResource


## Whether to allow editing of this PersistenceKey's key-name. [br]
##
## [b]WARNING:[/b] Altering a key-name will invalidate save data and should
## generally not be done after you've started using a key. If you must, plan a
## migration strategy for the [PersistenceDictionary]. [br]
##
## If you just want to edit the public description of this key, consider
## altering [member resource_name] instead.
@export var _edit_key_name := false:
  set(value):
    _edit_key_name = value;
    if _edit_key_name:
      _push_editable_key_error();
    notify_property_list_changed();

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


## Whether this [Resource] has finished being deserialized.
var _deserialized := false;


func _init() -> void:
  _deserialize_ready.call_deferred();


func _deserialize_ready() -> void:
  _deserialized = true;
  var editable_when_loaded := (_edit_key_name);
  var is_not_yet_configured := (not key_uid);

  if editable_when_loaded:
    _push_editable_key_error();

  if is_not_yet_configured:
    key_uid = _generate_key_uid();
    _edit_key_name = true;


func _validate_property(property: Dictionary) -> void:
  if (
      not _edit_key_name and property.name == 'persistence_key'
      or property.name == 'key_uid'
  ):
    property.usage |= PROPERTY_USAGE_READ_ONLY;


func _get_key() -> StringName:
  var key := key_uid;

  if persistence_key.length() > 0:
    key += ': %s' % persistence_key;

  return key;


## Returns a string with a unique-ish random set of characters.
func _generate_key_uid() -> StringName:
  return "Pkey_%s%s" % [
    generate_scene_unique_id(),
    generate_scene_unique_id().left(3),
  ];


## Push an error reminding the developer to unset [member _edit_key_name].
func _push_editable_key_error() -> void:
  if not _deserialized:
    return;

  push_error("The PersistencyKey '%s' is flagged as key-editable.\n  Path: %s" % [_get_key(), resource_path]);
