## A module to wrap the various player components into one package.
## This includes the player-operated avatar, their associated inventories and other
## systems, their perspective camera and UI systems, etc.
##
## **Note:** This is not intended to represent the player avatar as a whole. You should
## retrieve the `func get_entity() -> Player2D` object for manipulation and ignore this
## object's properties (e.g. `prop position`) unless you really know what you're doing.
@tool
class_name PlayerModule
extends GridEntityModule


var _camera: Camera2D;


func _get_property_list() -> Array[Dictionary]:
  var properties: Array[Dictionary];

  properties.append({
    name = "_entity",
    type = TYPE_NODE_PATH,
    hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
    hint_string = 'Player2D',
  });
  properties.append({
    name = "_camera",
    type = TYPE_NODE_PATH,
    hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
    hint_string = 'Camera2D',
  });

  return properties;


func get_entity() -> Player2D:
  return _entity;


func get_camera() -> Camera2D:
  return _camera;
