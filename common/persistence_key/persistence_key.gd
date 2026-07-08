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
extends Resource


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
## it is not guaranteed to be unique. If you need to modify it, enable this
## property in the 'Enable Edit Flags' group, **but be warned** this may
## invalidate user save data. Plan a migration strategy if a key is already
## being used.
@export var key_uid: StringName;

## The default value of this persistence key.
@export var _initial_value: Variant;


@export_group('Enable Edit Flags')

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


## Sets the value of the persistence key to [param value].
func write(value: Variant) -> void:
  assert(_value_type_valid(value),
    "Cannot assign value of type %s to persistence key of type %s." % [typeof(value), _get_value_type()]);
  PersistenceDictionary.write(key_uid, value);


## Returns the value of this persistence key.
func read() -> Variant:
  return PersistenceDictionary.read(key_uid, _initial_value);


## Erases this persistence value from the global dictionary. Returns true if a
## value existed, otherwise false.
func erase() -> bool:
  return PersistenceDictionary.erase(key_uid);


## Returns a string with a unique-ish random set of characters.
func _generate_key_uid() -> StringName:
  return "Pkey_%s%s" % [
    generate_scene_unique_id(),
    generate_scene_unique_id().left(3),
  ];


## Returns the value type of this persistence key.
func _get_value_type() -> Variant.Type:
  return typeof(_initial_value) as Variant.Type;


## Returns true if [param value] is of the same assigned [Variant.Type] as this
## persistence value.
func _value_type_valid(value: Variant) -> bool:
  var preferred_type := _get_value_type();
  return (
    typeof(value) == preferred_type
    or preferred_type == TYPE_NIL
  );


## Push an error reminding the developer to unset [member _edit_key_uid].
func _push_editable_key_error() -> void:
  if not _deserialized:
    return;

  var display_key_name := key_name if key_name else '[unnamed]';
  push_error(
    "The PersistencyKey '%s: %s' is flagged as key-editable.\n  Path: %s"
    % [key_uid, display_key_name, resource_path]
  );
