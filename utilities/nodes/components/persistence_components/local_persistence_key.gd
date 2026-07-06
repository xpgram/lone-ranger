@tool
## A [Resource] to formalize the [PersistenceKey] management of a particular key
## local to a [PackedScene].
class_name LocalPersistenceKey
extends PersistenceKeyResource


## The name of this persistence key. It is ideal to name it something human
## readable and debuggable.
@export var persistence_key: StringName;

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


func _property_can_revert(property: StringName) -> bool:
  if property == &'key_uid':
    print(key_uid != resource_scene_unique_id, ': ', key_uid, ' != ', resource_scene_unique_id)
    return (key_uid != resource_scene_unique_id);

  return false;


func _property_get_revert(property: StringName) -> Variant:
  if property == &'key_uid':
    return resource_scene_unique_id;

  return null;


func _get_key() -> StringName:
  var key := key_uid;

  if persistence_key.length() > 0:
    key += ' %s' % persistence_key;

  return key;


# func _validate_property(property: Dictionary) -> void:
# 	if property.name == "room":
# 		match area:
# 			Area.Area1:
# 				room = Room.Room1
# 				property.hint_string = "Room 1:0,Room 2:1"
# 			Area.Area2:
# 				room = Room.Room3
# 				property.hint_string = "Room 3:2,Room 4:3"


# func _property_can_revert(property: StringName) -> bool:
# 	if property == "room":
# 		# room default value depends on the area so we need to use a custom revert value
# 		return true

# 	return false


# func _property_get_revert(property: StringName) -> Variant:
# 	if property == "room":
# 		# return the default value depending on the area
# 		match area:
# 			Area.Area1:
# 				return Room.Room1
# 			Area.Area2:
# 				return Room.Room3

# 	return null
