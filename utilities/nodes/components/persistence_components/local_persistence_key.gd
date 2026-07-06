@tool
## A [Resource] to formalize the [PersistenceKey] management of a particular key
## local to a [PackedScene].
class_name LocalPersistenceKey
extends PersistenceKeyResource


## A unique identifier used to avoid naming conflicts between persistence keys. [br]
##
## Note that because this is an editable field, this cannot be strictly enforced.
## It is generally preferable to let the object set its own [member key_uid], and
## only modify it to resolve issues.
@export var key_uid: StringName:
  set(value):
    if value == '':
      value = resource_scene_unique_id;
    key_uid = value;

## The name of this persistence key. It is ideal to name it something human
## readable and debuggable.
@export var persistence_key: StringName;


func _get_key() -> StringName:
  var key := key_uid;

  if persistence_key.length() > 0:
    key += ' %s' % persistence_key;

  return key;
