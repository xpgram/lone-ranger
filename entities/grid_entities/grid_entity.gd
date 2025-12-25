## An object which maintains a position on the Grid.
class_name GridEntity
extends Node2D


## Emitted when this entity changes its position on the Grid.
signal entity_moved();


# TODO As I add more conditions here, I should consider extracting them to a Resource.
#   Having to go through every monster and object I've ever created just to check
#   'pushable' is irritating.

## Whether this entity obstructs the travel of other entities, like walls do.
@export var solid := false;

## Whether this entity can be forcibly moved into another Grid position.
@export var pushable := false;

## Whether this entity adheres to the more turn-based golem time instead of the ongoing
## action timer.
@export var observes_golem_time := false;

# TODO This attribute-tag system should be a component node, actually.
## A dictionary of applied effects and qualities.
@export var _attributes: Dictionary[StringName, GridEntityAttribute];


## The orientation of this entity, or which cardinal direction it is looking in.
var faced_direction := Vector2i.DOWN:
  get():
    return faced_direction;
  set(dir):
    faced_direction = dir;
    _facing_changed();

## The Grid coordinate position this entity is facing.
var faced_position: Vector2i:
  get():
    return grid_position + faced_direction;

## This object's position on the Grid.
## When setting this value, this object's Grid position is automatically updated.
var grid_position: Vector2i:
  get():
    return Grid.get_grid_coords(global_position);
  set(grid_vector):
    Grid.remove(self, grid_position);
    global_position = Grid.get_world_coords(grid_vector);
    Grid.put(self, grid_position);
    entity_moved.emit();


func _enter_tree() -> void:
  Grid.put(self, grid_position);


func _exit_tree() -> void:
  Grid.remove(self, grid_position);


## Returns true if `param attribute_name` is among the _attributes applied to this entity.
func has_attribute(attribute_name: StringName) -> bool:
  return _attributes.has(attribute_name);


## Returns the Attribute object for an attribute applied to this entity.
func get_attribute(attribute_name: StringName) -> GridEntityAttribute:
  # This may be refactor to .get(key, default) if I can think of what a useful default
  # might be.
  return _attributes[attribute_name];


## Applies an attribute to this entity. If this attribute was already applied, then the
## given attribute will merge with the existing one.
func apply_attribute(attribute_name: StringName, data: GridEntityAttribute) -> void:
  if _attributes.has(attribute_name):
    _attributes[attribute_name] = _attributes[attribute_name].merge(data);
  else:
    _attributes[attribute_name] = data;


## Iterates over the entity's collection of _attributes, updating their metrics, and
## removing them if their nullified.
func update_attributes() -> void:
  for attribute_key in _attributes:
    var attribute := _attributes[attribute_key];

    attribute.update();

    if attribute.is_nullified():
      _attributes.erase(attribute_key);


## Returns the Grid distance between this entity and [param other]. [br]
##
## [param other] is a [GridEntity] or a [Vector2i].
func distance_to(other: Variant) -> int:
  var other_pos: Vector2i = other.grid_position if other is GridEntity else other;
  var distance_vector := (grid_position - other_pos).abs();
  return distance_vector.x + distance_vector.y;


## Overridable function called whenever this GridEntity's facing direction is changed.
## Useful for updating sprite animations.
func _facing_changed() -> void:
  pass
