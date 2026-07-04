# @tool
##
class_name LocalPersistenceKey
extends PersistenceKeyComponent


##
@export var key_uid: StringName:
  set(value):
    if value == '':
      value = str(get_instance_id());
    key_uid = value;

##
@export var persistence_key: StringName;


func _get_key() -> StringName:
  var key := key_uid;

  if persistence_key.length() > 0:
    key += ' %s' % persistence_key;

  return key;
