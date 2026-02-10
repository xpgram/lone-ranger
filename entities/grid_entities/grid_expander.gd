## A component to allow GridEntities to inhabit multiple cells on the Grid.
class_name GridExpander
extends Node2D

# TODO This system for building double-chests and the like is barely thought out.
#  For one, a FieldAction like Move does not account for extra-size GridEntities when
#  checking collisions.
#  I need a formula to turn a set of rectangles into a list of grid_positions, or a way to
#  draw a set of active cells, and these possibly need to be incorporated into the
#  GridEntity class proper.
#  GridEntity.get_area(), then, would return the list of inhabited grid_positions, and
#  actions like Move could perform checks against all of them.

@export var grid_entity: GridEntity;

## Keeps track of the Expander's position on the Grid.
var _grid_position: Vector2i;


func _ready() -> void:
  _grid_position = Grid.get_grid_coords(global_position);
  grid_entity.grid_position_changed.connect(_update_grid_position);

  _update_grid_position();


func _update_grid_position() -> void:
  Grid.remove(grid_entity, _grid_position);
  _grid_position = Grid.get_grid_coords(global_position);
  Grid.put(grid_entity, _grid_position);
