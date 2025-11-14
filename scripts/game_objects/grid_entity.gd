## An object which maintains a position on the Grid.
class_name GridEntity
extends Node2D


## Whether this entity obstructs the travel of other entities, like walls do.
@export var obstructive := false;


## This object's position on the Grid.
## When setting this value, this object's Grid position is automatically updated.
var grid_position: Vector2i:
  get():
    return Grid.get_grid_coords(position);
  set(grid_vector):
    Grid.remove(self, grid_position);
    position = Grid.get_world_coords(grid_vector);
    Grid.put(self, grid_position);


func _ready() -> void:
  Grid.put(self, grid_position);
