## A module to wrap various GridEntity components into one package.
## For an example of how this may be used, see `class PlayerModule`.
##
## **Note:** This is not intended to represent the wrapped entity as a whole. You should
## retrieve the `func get_entity() -> GridEntity` object for manipulation and ignore this
## object's properties (e.g. `prop position`) unless you really know what you're doing.
@tool
class_name GridEntityModule
extends Node2D


## The Grid entity wrapped by this module.
## **Note:** use `func get_entity()` instead to get correct static typing.
var _entity: GridEntity;


func _get_property_list() -> Array[Dictionary]:
  var properties: Array[Dictionary];

  # For inspector type-overriding purposes, this property is only exported if this
  # object is a GridEntityModule specifically and not any inheriting type.
  if get_script() == GridEntityModule:
    properties.append({
      name = "_entity",
      type = TYPE_NODE_PATH,
      hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES,
      hint_string = 'GridEntity',
    });

  return properties;


## Returns the Grid entity wrapped by this module.
func get_entity() -> GridEntity:
  return _entity;
