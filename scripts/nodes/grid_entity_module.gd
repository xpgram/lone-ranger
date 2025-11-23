## A module to wrap various GridEntity components into one package.
## For an example of how this may be used, see `class PlayerModule`.
##
## **Note:** This is not intended to represent the wrapped entity as a whole. You should
## retrieve the `func get_entity() -> GridEntity` object for manipulation and ignore this
## object's properties (e.g. `prop position`) unless you really know what you're doing.
@tool
class_name GridEntityModule
extends Node2D


# TODO Make this a button?
# TODO Automatically hide by context? "am I a tscn? then hide all children"
## If true, child elements other than the wrapped entity are hidden.
@export var hide_elements := false:
  set(value):
    hide_elements = value;
    _set_element_visibility(not hide_elements);


## The Grid entity wrapped by this module.
## **Note:** use `func get_entity()` instead to get correct static typing.
var _entity: NodePath;


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


func _ready() -> void:
  _set_element_visibility(hide_elements);


# TODO Wait for a _entity.queue_freed signal and destroy self.
#  exit_tree() might do, but we can write our own that's more specific, I think.


## Returns the Grid entity wrapped by this module.
func get_entity() -> GridEntity:
  return get_node(_entity);


## Sets the visibility of all nodes other than the wrapped entity to `param is_visible`.
func _set_element_visibility(is_visible: bool) -> void:
  if not Engine.is_editor_hint():
    return;

  for child in get_children():
    child.visible = is_visible;
  
  get_entity().visible = true;
