## An object which maintains a position on the Grid.
class_name GridEntity
extends Node2D


# TODO As I add more conditions here, I should consider extracting them to a Resource.
#   Having to go through every monster and object I've ever created just to check
#   'pushable' is irritating.

## Whether this entity obstructs the travel of other entities, like walls do.
@export var solid := false;

## Whether this entity can be forcibly moved into another Grid position.
@export var pushable := false;


# TODO This dictionary needs an interface.
#   We need ways to quickly apply things like 'poison' without having to check if we're
#   erasing a previous, worse application and such.
## A dictionary of applied effects and qualities.
@export var tags: Dictionary[StringName, EntityTagData];

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
    return Grid.get_grid_coords(position);
  set(grid_vector):
    Grid.remove(self, grid_position);
    position = Grid.get_world_coords(grid_vector);
    Grid.put(self, grid_position);


func _enter_tree() -> void:
  Grid.put(self, grid_position);


func _exit_tree() -> void:
  Grid.remove(self, grid_position);


## Overridable function called whenever this GridEntity's facing direction is changed.
## Useful for updating sprite animations.
func _facing_changed() -> void:
  pass
