@tool
## A [Resource] interface for a key value in the global [PersistenceDictionary]. [br]
##
## This type allows a persistence key to take advantage of the Resource UID
## system, meaning that this key-object may be referenced by multiple object
## fields while maintaining a only single definition. [br]
##
## [b]Note:[/b] This type requires that [PersistenceDictionary] is a global
## autoload to function.
class_name PersistenceKey
extends PersistenceKeyResource


# [TODO] Merge this script with PersistenceKeyResource.
#   I no longer think they need to be different, really.
#   And I want to move _initial_value higher up in the inspector.
# [TODO] Hide _edit_key_uid in a group called "Enable Edit Flags".


## The name of this persistence key. This also sets the [member resource_name]
## and is only for developer purposes.
@export var key_name: String:
  get():
    return resource_name;
  set(value):
    resource_name = value;

## A pseudo-unique random identifier used to access a value in the
## [PersistenceDictionary]. [br]
##
## This value is auto-generated with enough variability to avoid collisions, but
## it is not guaranteed to be unique. If you need to modify it, check the box
## below to enable editing, **but be warned** this may invalidate user save data.
## Plan a migration strategy if a key is already being used.
@export var key_uid: StringName;

## Whether to allow editing of the key's UID. [br]
##
## [b]WARNING:[/b] Altering a UID will invalidate save data. If you must, plan
## a migration strategy for the [PersistenceDictionary].
@export var _edit_key_uid := false:
  set(value):
    _edit_key_uid = value;
    if _edit_key_uid:
      _push_editable_key_error();
    notify_property_list_changed();


## Whether this [Resource] has finished being deserialized.
var _deserialized := false;


func _init() -> void:
  _deserialize_ready.call_deferred();


func _deserialize_ready() -> void:
  _deserialized = true;
  var editable_when_loaded := (_edit_key_uid);
  var is_not_yet_configured := (not key_uid);

  if editable_when_loaded:
    _push_editable_key_error();

  if is_not_yet_configured:
    key_uid = _generate_key_uid();


func _validate_property(property: Dictionary) -> void:
  if not _edit_key_uid and property.name == 'key_uid':
    property.usage |= PROPERTY_USAGE_READ_ONLY;


func _get_key() -> StringName:
  return key_uid;


## Returns a string with a unique-ish random set of characters.
func _generate_key_uid() -> StringName:
  return "Pkey_%s%s" % [
    generate_scene_unique_id(),
    generate_scene_unique_id().left(3),
  ];


## Push an error reminding the developer to unset [member _edit_key_uid].
func _push_editable_key_error() -> void:
  if not _deserialized:
    return;

  var display_key_name := key_name if key_name else '[unnamed]';

  push_error(
    "The PersistencyKey '%s: %s' is flagged as key-editable.\n  Path: %s"
    % [key_uid, display_key_name, resource_path]
  );
